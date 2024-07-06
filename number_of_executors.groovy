import jenkins.model.Jenkins

// parameter to tweak default number of executors
Integer numberOfExecutors = 6

// get Jenkins instance
def jenkins = Jenkins.getInstance()

// set the number of slaves
jenkins.setNumExecutors(numberOfExecutors)

// save current Jenkins state to disk
jenkins.save()