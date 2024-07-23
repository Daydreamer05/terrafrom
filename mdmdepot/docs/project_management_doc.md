# Project Management Process Documentation

This is the first stage in the pipeline. 

## Prerequisite Check
The following steps are being performed in this job:
* Checks if GITLAB_TOKEN has a value assigned to it before running the job otherwise exits
* Uses --allow-releaseinfo-change with apt-get update
    * This allows the update command to continue downloading data from a repository which changed its information of the release contained in the repository indicating e.g a new major release. APT will fail at the update command for such repositories until the change is confirmed to ensure the user is prepared for the change. 
* Installs json query (jq) for command line
* Checks if the merge request is marked as draft and exits if it is marked as draft and the pipeline fails
* Checks if the merge request has assignees and if not assigned it exits and the pipeline fails
* Checks if time estimate and total time spent is specified in merge request, if not it exits and the pipeline fails
* Gets all the issues that would be closed by merging the provided merge request and stores it.
* If it returns nothing then the pipeline exits with error code 0 i.e. job exits without failing
* Gets the count of issues that have description and compares it with total number of issues  
* If the values do not match then it means description is not added for all the issues. Therefore, it exits the job and pipeline fails
* From the issues, those with labels as ‘Doing’ are retrieved
* Checks if the issue is a task. If it is a task then it exits the pipeline with error code 0 i.e. job exits without failing. (There is no check to find out the time estimate and time spent corresponding to the task)
* If not then it checks if these issues have time estimate and total time spent. If not present it exits and the pipeline fails
* Adds the header to the closedissue list and echos it for debugging purpose

This job will be executed only when there is an open merge request on the branch 



## Commit Lint 
Uses commit lint to ensure that commit messages adhere to commit convention. By supporting npm-installed configurations it makes sharing of commit conventions easy.

The following steps are being performed in this job:
* Uses the node:latest image for installing the node packages
* To install the packages at instance level following steps are performed:-
    * We use npm config cmd to specify that the root level group is hex and then set it as the default registry for npm execution
    * It then specifies the auth token for authentication
    * Then it installs the commitlint-cli and commitlint-config-conventional packages
* It then updates the commitlint.config.js file with some specific rules 
    * This step changes some of the default rules in commitlint-config-conventional package such as changing the default min-length to 2 instead of 0 for some parameters.
* It checks if there is a MR diff. If not it exits without failing the job
* Then it uses the MR diff base SHA to run commitlint to ensure commit title and commit description follow the commit convention. 

This job will be executed only when there is an open merge request on the branch 

