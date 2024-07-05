# create-jenkins-docker-image-and-publish-periodically
Create jenkins docker images and build them periodicaly and scan using trivy


docker built --build-arg JENKINS_USER=<user> --build-arg JENKINS_PASS=<passwd> -t <imagename:imagetag>