# create-jenkins-docker-image-and-publish-periodically
Create jenkins docker images and build them periodicaly and scan using trivy

# Images being built and updated

| Image Name                                   | jdk version |
|----------------------------------------------|--------------|
| dockerofkrishnadhas/jenkins-core-image       | jdk11 |
| dockerofkrishnadhas/jenkins-core-jdk17-image | jdk17 |
| dockerofkrishnadhas/jenkins-core-jdk21-image | jdk21 |

# How everything works

* Dockerfile --> The core instructions on building jenkins docker image

* plugins.yaml --> The list of plugins installed in java once booted by default. its file name should be either plugins.yaml or plugins.txt

* user.groovy --> This creates a user with name as of `JENKINS_USER` and with password `JENKINS_PASS` who will be the default user and security will be enabled using `Jenkins OWN Databse` by default.

* number_of_executors.groovy --> this script is used to increase the `numOfExecutors` in Jenkins from 2 to `x` where `x` is the value of numberOfExecutors provided in the script.

* get_latest_version_create_tag.sh --> gets the tag to create on github and set it as a github env variable and push tag to github

* config-as-code.yaml --> This uses Configuration as Code plugin from Jenkins to set up some default settings like setting up a GitHub App as a credential.

* **To use JCasC, you need to install the Configuration as Code plugin.** [configuration-as-code](https://plugins.jenkins.io/configuration-as-code/)

* examples of how to use config as code plugin [jenkinsci/configuration-as-code-plugin](https://github.com/jenkinsci/configuration-as-code-plugin/tree/master/demos/role-strategy-auth)

* The jenkins/jenkins image allows you to enable or disable the setup wizard by passing in a system property named `jenkins.install.runSetupWizard` via the JAVA_OPTS environment variable. Users of the image can pass in the JAVA_OPTS environment variable at runtime using the --env flag to docker run. However, this approach would put the bonus of disabling the setup wizard on the user of the image. Instead, you should disable the setup wizard at build time, so that the setup wizard is disabled by default.

# Softwares Installed in Jenkins

* Docker Latest available version for Debian.

* Azure CLI latest available version for Debian.

* Latest Jenkins CLI version to install plugin manager and install plugins.

# How to run the code locally
* make sure docker and docker-compose are present on your machine
* clone the repo
* cd to the repo directory
* To build the image locally, use

` docker build --build-arg JENKINS_USER=<your user name> --build-arg JENKINS_PASS=<your passaword here> -t <image name: image tag> .`

Replace the **JENKINS_USER** , **JENKINS_PASS** with your values.

Eg:  docker build --build-arg JENKINS_USER=user --build-arg JENKINS_PASS=password -t devwithkrishna-jenkins-image:latest .

***The . at the end of docker build command is mandatory***

:round_pushpin: **GITHUB_APP_KEY** , **GITHUB_APP_ID** are required by configuration as code plugin to set up GitHub app credentials :round_pushpin:

:pushpin:These values **GITHUB_APP_KEY** , **GITHUB_APP_ID** will be passed as environment variables on deployment time either through docker compose file or as -e flag.

# Things to remember
* When configuring up the GitHub app credential in Jenkins, it needs to be in a specific format .
    Details can be found here - [github-app-auth](https://docs.cloudbees.com/docs/cloudbees-ci/latest/cloud-admin-guide/github-app-auth)

* Post generating the Private key of GitHub app, this needs to be converted into a specific format 
    Use the command [here](https://docs.cloudbees.com/docs/cloudbees-ci/latest/cloud-admin-guide/github-app-auth#_converting_the_private_key_for_jenkins) , This will be the value we will be passing as `GITHUB_APP_KEY`

  ```
  openssl pkcs8 -topk8 -inform PEM -outform PEM -in <key-in-your-downloads-folder.pem> -out <converted-github-app.pem> -nocrypt
  ```
  * <key-in-your-downloads-folder.pem> --> Replace with your pem file path of app private key.
  * <converted-github-app.pem> --> The converted output which you need to update to jenkins.

I am passing the `GITHUB_APP_KEY` & `GITHUB_APP_ID` at build time from github secrets and storing it as env variables in image.

# Image 👉 [jenkins-core-image available here](https://hub.docker.com/r/dockerofkrishnadhas/jenkins-core-image)
