# Base image referring official build from jenkins - jdk 11
FROM jenkins/jenkins:lts-jdk11
# Jenkins default user and password will be passed on run time
ARG JENKINS_USER
ARG JENKINS_PASS
ENV JENKINS_PASS=${JENKINS_PASS}
ENV JENKINS_USER=${JENKINS_USER}
# Added a label
LABEL authors="githubofkrishnadhas"
# Root user
USER root
# Install basic packages needed
RUN apt-get update -y \
  && apt-get install --no-install-recommends -y -qq \
    ca-certificates \
    curl \
    apt-transport-https \
    gnupg \
    wget \
    software-properties-common \
    lsb-release \
    git \
    vim \
    unzip \
    jq \
  && apt-get upgrade -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /var/cache/apk/*
# Install docker
RUN  apt-get update -y && \
     install -m 0755 -d /etc/apt/keyrings && \
     curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
     chmod a+r /etc/apt/keyrings/docker.asc && \
      echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null && \
     apt-get update && \
     apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y && \
     usermod -a -G docker jenkins
# Install azure cli latest available version for debian
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash
# Fetch the latest release data from GitHub API & Install Jenkins CLI to install plugin manager
RUN latest_release=$(curl -s https://api.github.com/repos/jenkinsci/plugin-installation-manager-tool/releases/latest | jq 'del(.body)') && \
    echo "GitHub API response:" && echo "$latest_release" && \
    tag_name=$(echo "$latest_release" | jq -r .tag_name) && \
    echo "Latest release tag of plugin-installation-manager-tool: $tag_name" && \
    download_url=$(echo "$latest_release" | jq -r '.assets[] | select(.name | endswith(".jar")) | .browser_download_url') && \
    echo "Download URL: $download_url" && \
    curl -fsSL "${download_url}" -o $JENKINS_HOME/jenkins-plugin-manager.jar
# copy plugins.yaml file for installing plugins using jenkins cli
COPY plugins.yaml ${JENKINS_HOME}/plugins.yaml
# Copy user.groovy to /usr/share/jenkins/ref/init.groovy.d/ where will setup the default admin user and password:
COPY user.groovy /usr/share/jenkins/ref/init.groovy.d/
# Configuration as code and set as a environment variable
COPY ./config-as-code.yaml $JENKINS_HOME/config-as-code.yaml
ENV CASC_JENKINS_CONFIG=$JENKINS_HOME/config-as-code.yaml
# Install plugin using jenkins cli
RUN java -jar $JENKINS_HOME/jenkins-plugin-manager.jar --plugin-file $JENKINS_HOME/plugins.yaml --plugin-download-directory ${JENKINS_HOME}/plugins --output yaml
# File permissions for JENKINS_HOME for jenkins user
RUN chown -R jenkins:jenkins /var/jenkins_home && \
    chmod -R 755 /var/jenkins_home
# Switching to default user
USER jenkins
# Skip initial setup
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"


