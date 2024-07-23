# SEMANTIC VERSIONING DOCUMENTATION 


 

## Stage: Publish 

### Job: Publish 

This job will run only when the branch or tag name for which project is built is either master or develop or alpha.  

Semantic-release automates the whole package release workflow including: determining the next version number, generating the release notes, and publishing the package. It uses the commit messages (e.g., feat, fix, perf, etc.) to determine the consumer impact of changes in the codebase. 

Before running semantic-release command $GIT_SSL_NO_VERIFYis set to true to skip ssl verification. Then additional plugins are installed as devDependencies. Plugins installed are the follows: 

@semantic-release/git: Verifies the presence and the validity of the Git authentication and release configuration and then pushes a release commit and tag, including configurable files. 

 
@semantic-release/changelog: Verifies the presence and the validity of the configuration and then create or update the changelog file in the local project repository 

@semantic-release/gitlab-config: It is the semantic-release shareable config to publish npm packages with GitLab. 

@semantic-release/exec: Does the following steps 

- verifyConditions: Execute a shell command to verify if the release should happen 

- analyzeCommits: Execute a shell command to determine the type of release 

- verifyRelease: Execute a shell command to verifying a release that was determined before and is about to be published 

- generateNotes: Execute a shell command to generate the release note 

- prepare: Execute a shell command to prepare the release 

- publish: Execute a shell command to publish the release 

- success: Execute a shell command to notify of a new release 

- fail: Execute a shell command to notify of a failed release 

Then npx semantic-release is run with debug flag which finds the semantic-release binary and executes it. Version used is 17.0.4 This will use the .releaserc.json file in the dlp/services/dlp repository root. 

If the branch is ‘develop’ then distribution channel on which to publish releases is ‘dev’. Prerelease is given as ‘dev’ for pre-release denotation to append to semantic versions released from this branch. Similarly, if branch is ‘master’, then release channel is ‘canary’. If branch is ‘stable’, release channel is ‘stable’ and range of semantic versions to support on that branch is ‘1.4.x’. Finally, if branch is ‘lts’ release channel is ‘lts’ and range of semantic versions to support on that branch is ‘1.0.x’.  

Changelogs are written into CHANGELOG.md file in root of dlp/services/dlp repository. 

 
