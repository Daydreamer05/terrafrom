# Cluster Version Upgrades

## Table of Contents

- [Kubernetes Version](#kubernetes-version)
- [Gloo Version](#gloo-version)

## Kubernetes Version

### Prerequisite Checks

- Deprecated APIs   
Check for apis which will be deprecated while updating to higher version and update the same in manifest files. One tool which can be used for same is [kubent](https://github.com/doitintl/kube-no-trouble).
- AWS default-addons 
Check whether existing aws default-addons; kube-proxy, aws-node and coredns versions will be compatible with new kubernetes version. If version incompatibility arises upgrade the same before upgrading cluster as it might cause issues while creation of nodes after cluster upgrade.
- Cluster Autoscaler   
Check whether existing Cluster Autoscaler(CA) version is compatabile with new version. If version incompatibility arises upgrade the same.
- Pod Disruption Budget   
Ensure Pod Disruption Budget(PDB) is set properly for minimum availability of services during node group upgrade process.

### Cluster Updation Steps

CI Job is present to handle cluster kubernetes version upgrade.

- **Updating Cluster using CI job**

1. Do prerequiste checks
2. To Run CI job update cluster version in `${ENVIRONMENT}/cluster.yaml` file, where ENVIONMENT is dev/qa.
3. Update `CA_VERSION` variable value in CA deployment job if cluster autoscaler update is needed.
4. After MR is merged to master, manually trigger the updation stage jobs for each cluster.
5. Deprecation check job will run after cluster version upgrade to check for deprecated apis.

- **General Cluster Upgrade process steps**

1. Do prerequiste checks
2. Upgrade control plane version (cluster version)
    ```sh
    eksctl upgrade cluster --config-file cluster.yaml --approve
    ```
3. Upgrade each node-group version 
    ```sh
    eksctl upgrade nodegroup --name=<node_group_name> --cluster=$CLUSTER --kubernetes-version=<version>
    ```
4. Update default add-ons; kube-proxy, aws-node and coredns. Each of them have separate upgrade commands
    ```sh
    eksctl utils update-kube-proxy --cluster=$CLUSTER --region $REGION --approve
    eksctl utils update-aws-node --cluster=$CLUSTER --region $REGION --approve
    eksctl utils update-coredns --cluster=$CLUSTER --region $REGION --approve
    ```
5. Check and ensure pods are in ready state for kube-system namespace(addon pods), gloo-system namespace(gloo-edge pods) and for deployed microservices.    

Reference: [Cluster-upgrade](https://eksctl.io/usage/cluster-upgrade/)


## Gloo Version

### Prepare the environment 
 - Upgrade current version to the latest patch (recommended in docs)
    - This ensures that the current environment is up-to-date with any bug fixes or security patches before we begin the minor version upgrade process. 
    - Find the latest patch of the current minor version and follow the upgrade guide
 - Check whether underlying infrastructure platform such as Kubernetes, Helm run a supported version
    - Reference: [Gloo Supported Versions](https://docs.solo.io/gloo-edge/latest/reference/support/#supported-versions)
 - Review the open source changelogs for the new Gloo Edge version. Go through the CRD, Helm, CLI, and Feature changes 
    - CRD Changes - delete any removed CRDs
    - Feature Changes - see whether there are any breaking changes that must be addressed in resources before upgrading the version
    - Helm Changes - see whether there are new, deprecated, or removed Helm settings. To make required changes use values.yaml file or --set flags in helm upgrade command.
 

### Gloo Upgradation Steps
- **Upgrade Gloo version using CI job**
1. Prepare the environment
2. Before running the CI job update the `GLOO_VERSION` variable in the utility/gloo-update.gitlab-ci.yml
3. If any helm settings needs to be changed update the helm upgrade command in gloo version upgrade job.
4. After MR is merged to master, manually trigger the updation stage jobs for each cluster.

- **General Gloo Version Upgrade steps**
1. Prepare the environment
2. Update and pull the gloo helm chart
    ```
    helm repo update
    helm pull gloo/gloo --version $NEW_VERSION --untar
    ```

3. Apply new and updated CRDs
    ```
    kubectl apply -f gloo/crds
    ```
    Run `glooctl check` command in cluster to check if gloo components are properly updated.

4. Upgrade the helm release. Use --set flag / values.yaml file to make required changes for the new gloo version.
    ```
    helm upgrade -n gloo-system gloo gloo/gloo --version=$NEW_VERSION
    ```
