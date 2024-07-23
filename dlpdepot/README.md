# Depot

This repository is designed to manage the k8s cluster configuration and terraform deployment. 

### Directory Structure

- **utility**: Contains Kubernetes YAML files for cluster building.
- **data_layer**: This folder contains the root Terraform configuration. This setup refers two modules:
  - **database**: Configures RDS and Elasticache. For RDS, it includes creating a security group, parameter group, subnet group, and the RDS DB instance. For Elasticache, it includes the same security group, parameter group, subnet group, and Elasticache node group.
  - **security_group**: Used for creating security groups.

- **cog_redis**: manages Elasticache configurations for Cog. This involves setting up a security group, a CloudWatch log group, a parameter group, a subnet group, and an Elasticache node group.

Both `data_layer` and `cog_redis` directories utilize `null_resource` to update CI variables.

- **dev**, **QA**, **PROD-US**: Each stage-specific folder contains:
  - `eksctl` configuration YAML file.
  - Terraform `tf-vars` file for stage-specific configurations.


## New Stage Deployment Steps

1. **Create IAM User for New Stage**:
   - Create an IAM user with the necessary permissions for the new stage.
   - Configure the IAM user credentials in gitlab ci variables to be used in the deployment process.

2. **Create EKS Cluster Using eksctl Config File**:
   - Use the `eksctl` configuration YAML file located in the respective stage folder (e.g., `dev`, `QA`, `PROD-US`) to create the EKS cluster.

3. **Create S3 Bucket and DynamoDB Table**:
   - Create S3 Bucket and DynamoDB Table for storing terraform state. 
   - Update the values for each stage in the `.gitlab/ci/<stage>/backend.hcl` file.

4. **Create Secrets in AWS Secrets Manager**:
   - Create a secret for RDS master/app-specific username and password.
   - Update the values in the respective `.tfvars` file for each stage.

5. **Run CI Jobs**:
   - Execute the CI jobs to deploy the infrastructure as per the configurations defined.

## Nodegroup

  - Add nodegroup configurations to config file
    
    ```bash
        eksctl create nodegroup --config-file=path_to_config.yaml --include=nodegroup_name
    ```

 - Deleting a nodegroup
    
    ```bash
        eksctl delete nodegroup --config-file=path_to_config.yaml --include=nodegroup_name --approve
    ```

    - Remove nodegroup from config file


## Upgrade Linkerd

Set desired version in `LINKERD_VERSION` ci variable under CI/CD settings.

Linkerd Upgrade job is configured to run on manual trigger when committing to master. This job will fetch version from `LINKERD_VERSION` variable and upgrade Linkerd to that version. 


To avoid creating new MR find last run Linkerd Upgrade job from pipeline history and select `Update CI/CI variables` from job retry options. Add variable `LINKERD_VERSION` with new version. Run job again.


## Terraform Deployment Steps

### 1. Initialize Terraform
- Initialize the Terraform configuration with the backend configuration for the specified stage.
- Do update the terraform aws provider version inside `main.tf` file regularly. 

```sh
terraform init -backend-config "/path/to/backend.hcl"
```
### 2. Create Terraform Workspace
```sh
terraform workspace new "stage_microservice"
```
### 3. Validate Terraform Configuration

```sh
terraform validate
```

### 4. Lint Terraform Files
- Terraform tflint plugin configuration files `.tflint.hcl` are stored in the **data_layer** and **cog_redis** folders, respectively.
- Do update the terraform tflint plugin version inside `.tflint.hcl` file regularly. 

```sh
tflint --init
tflint --var-file "/path/to/terraform.tfvars"
```
### 5. Plan Terraform Deployment
```sh
terraform plan --var-file "/path/to/terraform.tfvars"
```
### 6. Apply Terraform Configuration
```sh
terraform apply --var-file "/path/to/terraform.tfvars" --auto-approve
```
- After a successful apply, storing the terraform.tfstate file as a backup using aws s3 get-object command.

### 7. Destroy Terraform Resources
```sh
terraform destroy --var-file "/path/to/terraform.tfvars" --auto-approve
```

## Security Hub, AWS X-Ray and Guard Duty

DLP integrates with AWS Security Hub, AWS X-Ray, and AWS GuardDuty to provide comprehensive security and monitoring capabilities. AWS Security Hub centralizes and prioritizes security alerts, giving a unified view of your security status. AWS X-Ray helps trace and analyze user requests as they travel through your application, identifying performance bottlenecks and root causes of issues. AWS GuardDuty continuously monitors your AWS accounts and workloads for malicious activity and unauthorized behavior, using threat intelligence and machine learning.

- To activate Security Hub, first enable the **AWS Config** service, and then navigate to the Security Hub dashboard and enable it. It will take a day to see your security score. It is region scoped. Make sure you have enabled for the regions you want.
- To enable Guard Duty, simply go to the Guard Duty dashboard and turn it on. It will highlight the security threats connected with your AWS infrastructure.
- AWS X-Ray is a great tool for monitoring requests passing across your microservices architecture. We're integrating X-Ray at the K8s level. We can quickly examine in-depth request monitoring across complex microservices architectures.


## Prometheus & Grafana
- The k8s manifest files for Prometheus deployment are located in the `utility/prometheus-deployment` folder. Change the domain name in the `virtualservice.yml` file, then apply.
- After applying the k8s manifest files, map the loadbalancer DNS name to the domain name specified in `virtualservice.yml`.
- Then, within the Prometheus server, add a channel in `alertmanager.yml`. And webhooks may be added to gitlab monitoring or to the prometheus-msteams container, which runs within the Prometheus server.
- If we want alerts delivered to the Microsoft Teams channel, we can create a separate channel and add the webhook url to `config.yml` in the **prometheus_msteams** folder on the Prometheus server.
- By doing so, we may receive alertmanager notifications for the gitlab monitoring section or MS teams.

## Fluent Bit 
- The files are located in utility/fluentbit-agent.
- Create an S3 bucket and add the bucket name to fluent-bit-config.yaml.
- Then, in the configmap.yaml file, set the appropriate cluster name and Amazon Web Services region.
- Then you must deploy all of the files. Add the iam role service account in the amazon-cloudwatch namespace with S3 and cloudwatch permissions in cluster.
- Add the `LOG_DIR=/var/log/` variable to `.env` file. Also, add the following line as a `CMD` command to the microservice.
- Then, you must deploy apps with sidecar container settings to gather logs.


```
sed -i 's~file_handler = logging.FileHandler(f"{cls._APP}.log")~file_handler = logging.FileHandler(f"""{CONFIG("LOG_DIR", default="")}{cls._APP}.log""")~' /usr/local/lib/python3.9/site-packages/stencil/utils/logger.py
```