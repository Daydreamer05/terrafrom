# MDM Depository

The MDM product is built of independent projects each evolving at its own pace. This repository i.e **Depot** is just a dump of general information related to the product.

## Table of Contents

- [Structue](#structure)
- [Process](#process)
- [Workflow](#workflow)
- [Review App](#deploy-a-review-app-for-an-mr-to-review-the-changes-before-merging)
- [Adding packages to registry](#Adding-packages-to-registry)
- [Run Services using docker](#run-mdm-services-using-docker)
- [Utility Jobs](#deployed-app-utility-jobs)
- [Cluster Version Upgrades](https://codehub.mitsogo.com/mdm/depot/-/blob/master/docs/cluster_version_upgrades.md)

## Structure

As of today, the following projects are part of MDM:

- [RFCs](mdm/rfcs) - This repository holds all the feature/enhancement requests and the corresponding feature design.
- [Design](mdm/design) - This repository holds all the design files(Figma).
- [Contract](mdm/contract) - This repository holds all the contracts wrt API, Scenarios and Database.
- [Server](mdm/server) - This repository handles the main back-end code(Python).
- [Browser](mdm/browser) - This repository handles the main front-end code(Typescript/Javascript).


## Process

### 1. [Create an issue for new feature, enhancements and bugs in mdm/rfcs](https://gitlab.hexnode.com/mdm/rfcs/issues/new)

1. Depending on your request, choose a relevant template. For example,
- For a new feature, choose template: New-Feature
- For an enhancement, choose template: Enhancement
- For a bug, choose template: Bug
2. Fill out the issue details and **Save** it.
3. Involve as many people(especially the product manager) in the discussion by tagging them in the comments.
4. If you want to start a discussion thread within this issue, [click on Start discussion](https://docs.gitlab.com/ee/user/discussions/#threaded-discussions).

### 2. Plan

#### Product Managers

1. Set the priority.
2. Assign it to a *Feature Owner*.
3. Add it to a **project milestone**. Create one if not already available.
4. [Add estimated time in the comment](https://docs.gitlab.com/ee/workflow/time_tracking.html#estimates)

#### Feature Owners

PS: Do not create a MR for bugs until and unless it affects the product

1. Click on Create Merge Request button(or dropdown to create a branch).
2. Update Rendered file URL.
3. Create an RFC
4. Associate relevant projects by assigning labels. For example, a feature involving UI and Business logic will affect browser, contract, server.
5. DO NOT ASSIGN A MILESTONE.
6. Once completed, assign the MR to a *Reviewer*.

#### RFC Reviewer

1. Assign relevant *Approvers* and the min. approvals required.
2. Once approved, update `status::accepted` label.
3. If rejected, update `status::rejected` label.

#### Approvers

1. [Add comments if any](https://docs.gitlab.com/ee/user/discussions/#resolvable-comments-and-threads). 
2. Once resolved, approve the RFC based on your expertise.

#### Butler

When MR is created, it does the following:

1. Attach relevant labels based on the issue for which the MR was created.

Once the MR status is updated to "accepted", it does the following:

1. Create relevant issues in the respective project repositories.
2. Updates MR description with the above issues.
3. Once the above issues are fixed in their respective repositories, it marks it as completed in the MR description.

Once the MR status is updated to "rejected", it does the following:

1. Move proposal to "archive"
2. Merges the MR
3. Deletes the branch


### Start project specific implementation

Once Butler creates an issue in a project

#### Feature Owners

1. Assigns it to his/her own name or to another colleague.
2. Assigns a project milestone like 2.4.3
3. Create one or more MRs and relate it to the issue. If there is only one MR associated with the issue, you can use the [default pattern](https://docs.gitlab.com/ee/user/project/issues/managing_issues.html#default-closing-pattern). 
4. Assign a weekly milestone to the MR.
5. Assign relevant labels.
6. Start work.
7. Once work is completed, assign the MR to a *Reviewer*

#### Reviewer

1. Check for relevant meta data like milestone, etc.
2. Assign relevant *Approvers* and the min. approvals required.
3. Once approved, update `status::accepted` label.
4. If rejected, update `status::rejected` label.

#### Butler

Once the MR status is updated to "accepted", it does the following:

1. Create relevant issues in the respective project repositories.
2. Updates MR description with the above issues.
3. Once the above issues are fixed in their respective repositories, it marks it as completed in the MR description.

Once the MR status is updated to "rejected", it does the following:

1. Closes the MR
2. Deletes the branch

## Workflow

[For developers](https://gitlab.hexnode.com/mdm/depot/wikis/Developer-Workflow)

[For agents](https://gitlab.hexnode.com/mdm/depot/wikis/Agents-Workflow)


## Deploy a Review App for an MR to review the changes before merging

When developer creates an MR which has to be reviewed following the below steps a reviewer can deploy review app to visulaize the changes before merging:

1. When an MR is up for review the `Stage::Review` label will be applied and the developer has to add the required members as reviewers.
2. If the reviewers wish to deploy review apps for the changes in the MR they will have to assign the MR to `Butler`. This will trigger a pipeline that would deploy the review app . A url which points to the deployed app will be present as a button in the MR when the pipeline completes its execution.
3. Once the review app is deployed for an MR any subsequent changes made to the source branch would be updated in the review app. (Changes show up only after MR pipeline finishes runninng)
4. Now if reviewer is satisified with the changes he/she has to remove the `Stage::Review` label from the MR at this point Butler will unassign itself from the MR signaling the end of the review app deployment and thus triggering a subsequent Review Cleanup Job.

__NOTE__:
1. As a current limitation we can allow only 2 review apps to be deployed concurrently in a repository this means that if for a particular repository 2 review apps are already deployed then a request for deploying a 3rd review app for another MR will fail . However once one of the existing 2 review processes are completed simply rerunning the failed MR pipeline for review deployment should deploy the review app for your MR.
2. Once review process is completed reviewers have to make sure that `Stage::Review` label is removed from the MR . Only then will the review app corresponding to the MR be removed which would then allow review app deployments related to other MRs.

## Adding packages to registry

All third patry packages will be stored in the gitlab regitry and should only be used from there. In order to add a package to gitlab registry

- Create an issue in `depot` repo using `package-addition` template. (template needs to be followed strictly)
- Add `package` label to the issue.
- Inform Devops team 
- Package will be checked and added.

## Run MDM services using docker 

### Prerequisites

- Install slate-cli.
    - Reference: [slate-cli](https://codehub.mitsogo.com/hex/slate-cli)

- Run services using slate run command

    ```shell
    slate run <service> -i develop
    ```

- To run browser using slate-cli

  ```shell
  slate run browser -i develop -c "python server_url_update.py <ip>"
  ```

  We are using nginx to route the traffic to their respective servers based on path.

- To use latest images to run service server
  1. Remove existing images

      - Run:
        ```shell
        docker image rm $(docker image ls | grep develop | grep <service> | awk '{ print $3 }') -f
        ```
        *For example:- to remove cog images run: &nbsp;  docker image rm $(docker image ls | grep develop | grep cog  | awk '{ print $3 }') -f*
  2. Start server again 

#### To route traffic to local server

  For routing traffic between the browser and local server code, we have to run nginx server alone.
  The command to run the nginx server alone with local code

  ```shell
  slate run nginx -i develop -c "pap_ip:<ip:port>"
  ```

  For multiple servers

  ```shell
  slate run nginx -i develop -c "pap_ip:<ip:port>,endpoint_ip:<ip:port>,content_ip:<ip:port>..."
  ```



### Send requests to microservices 

To send request to a microservice use the below url
  ```shell
    http://localhost:8081
  ```

### Pap

Running Pap as a service runs pap_server, pap_db, prism, nginx and redis.
  ```shell
    slate run pap -i develop 
  ```

Before running any micro-service ensure that pap is running, as db replication is happening from pap to other microservices.


### Cog

Ensure that endpoint is running as it uses same db host and redis.   
Access webserver UI at `$IP:8800`.

### Userportal 

Replicates data from pap,endpoint,directory so ensure these micro-services are running.  
env.js file should be present in path `~/Projects/env.js` locally before running userportal.  

`env.js` file should have follwing variables. Replace cookie domain name and script source url with IP.  

```
export const ENV = {
  secureSession: {
    secretKey: process.env.SECRET_KEY_SECURE_SESSION,
    salt: process.env.SALT_SECURE_SESSION,
  },
  google: {
    clientId: process.env.GOOGLE_CLIENT_ID,
    clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    redirectUri: process.env.GOOGLE_REDIRECT_URI,
  },
  microsoft: {
    clientId: process.env.MICROSOFT_CLIENT_ID,
    clientSecret: process.env.MICROSOFT_CLIENT_SECRET,
    redirectUri: process.env.MICROSOFT_REDIRECT_URI,
  },
  okta: { redirectUri: process.env.OKTA_REDIRECT_URI },
  sslCertificateKey: process.env.SSL_CERTIFICATE_KEY,
  sslCertificatePrivateKey: process.env.SSL_CERTIFICATE_PRIVATE_KEY,
  db: {
    user: process.env.DB_USER,
    userPassword: process.env.DB_USER_PASSWORD,
    host: process.env.DB_HOST,
    name: process.env.DB_NAME,
    port: process.env.DB_PORT,
  },
  iosCheckInUrl:process.env.IOS_CHECK_IN_URL,
  windowsCheckInUrl:process.env.WINDOWS_CHECK_IN_URL,
  scriptSourceUrl: ,
  cookieDomainName: ,
  app:process.env.APP,
	mdmJwtSecret:process.env.MDM_JWT_SECRET,
  isTest:process.env.IS_TEST
};
```
<br>

To change portal name in tenant table execute 
```shell
docker exec -it endpoint_db psql -U postgres -d device_models -c 'UPDATE "common"."Tenant" SET name=<portal_name> WHERE id=2049;' 
```
where portal name is first 3 digits of IP address (For example: if IP = 192.168.16.111, portal_name = 192)

Access enroll server at `$IP:3000/enroll` 

### Checkinportal 

.env file should be present in path `~/Projects/.env`  locally before running checkinportal.  
Certs needed to run checkinportal in https should be placed in a directory (docker_certs) in path `~/Projects/docker_certs/` locally.  
Use [mkcert](#mkcert) to make necessary certs.

`.env` file should have following variables.
```
BEARER_TOKEN=
AWS_DEFAULT_REGION=
APP=
DEBUG=
HOST_NAME=
MODE=
AWS_DYNAMO_HOST=http://dynamodb-local:8000
APNS_CERT=
SCEP_ROOT_CERT=
MDM_SIGN_CERT=
MDM_SIGN_KEY=
MDM_HOST_NAME=
SCEP_URL=
HASHIDSALT=
``` 

### Scepportal 

Certs needed to run scepportal in https should be placed in a directory (docker_certs) in path `~/Projects/docker_certs/` locally.  
Use [mkcert](#mkcert) to make necessary certs. 

### Mkcert
[mkcert]: #mkcert
#### Install mkcert 

On Linux, first install `certutil`.

Then you can install using pre-built binaries.
```shell
curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64" 
chmod +x mkcert-v*-linux-amd64 
cp mkcert-v*-linux-amd64 /usr/local/bin/mkcert 
```

#### To create cert files run  

```shell
mkcert -key-file key.pem -cert-file cert.pem  $IP 
```
(give any vaild hostname, IP, URL or email) 

#### Instructions in using certs

Make sure that key file is named `key.pem` and cert-file `cert.pem`.   
Keep *key.pem*, *cert.pem* and *rootCA.pem* files in a common directory docker_certs (path: `~/Projects/docker_certs/`).   
Both checkinportal and scepportal uses same cert files to start server in https.  
Install rootCA.pem file in test device and enable full trust to enroll device. 

- Reference : [mkcert](https://github.com/FiloSottile/mkcert)

## Deployed app utility jobs

There are two ci jobs in category of deployed app utility jobs.  
These jobs are set in branch `ci_deployment_utility` in respective mdm/services repositories.
- **Server logs:** To view deployed app logs.
  <br> Configured in checkin windows, checkinportal, content, reports, pap, endpoint and userportal repositories.  
  Connects to respective apps deployed in mdm-qa cluster.
  For endpoint and pap both dev and qa server logs is configured.

- **Execute Query:** To execute sql queries.
  <br> Configured in content, pap, endpoint and userportal repositories.  
  Queries are executed in respective apps deployed in mdm-qa cluster.

#### To view latest server logs:
- Rerun latest `Server logs` job which ran in `ci_deployment_utility` branch

#### To execute sql queries:
- Checkout to `ci_deployment_utility` branch
- Add query to be executed in `.deployment/query.sql` file
- Commit changes made and check latest `Execute Query` job for output.


