# kubernetes-devops-security

## Fork and Clone this Repo

## Clone to Desktop and VM

## NodeJS Microservice - Docker Image -
`docker run -p 8787:5000 siddharth67/node-service:v1`

`curl localhost:8787/plusone/99`
 
## NodeJS Microservice - Kubernetes Deployment -
`kubectl create deploy node-app --image siddharth67/node-service:v1`

`kubectl expose deploy node-app --name node-service --port 5000 --type ClusterIP`

`curl node-service-ip:5000/plusone/99`

# Setup VM in GCP using gcp-vm-cloud-cmd folder
# create ssh key gen 
```t
ssh-keygen -t rsa -f ./gc_rsa -C sarsatis
```
# login to vm 
```t
ssh -i /Users/sarthaksatish/Desktop/Sarthak/rsa/gc_rsa sarsatis@34.28.94.32
sudo su
```

# Install Tools
Install other tools which are in vm-install-script

# Install Jenkins 

Install jenkins using my repository 2.1Jenkins folder

# Install Plugins
Intall plugins in inside jenkins folder

# Configure kubernetes cloud in jenkins
kubeconfig file will be available in
/root/.kube/config take the content of this file and create it as a secret in jenkins

# Jacoco plugin 
Add plugin in pom.xml and added post script

# add webhook
Remember to use GitHub instead of Git while configuring webhook
In git --> settings --> hooks --> http://34.28.94.32:30685/github-webhook/ --> application/json

# Create a node app
k create deploy node-app --image siddharth67/node-service:v1
k expose deploy node-app --name node-service --port 5000

# Have the entire basic
Create jenkins file with package,test,docker build and app installed to k8s

# Talisman
https://github.com/thoughtworks/talisman#installation-to-a-single-project
```t
# Download the talisman installer script
curl https://thoughtworks.github.io/talisman/install.sh > ~/install-talisman.sh
chmod +x ~/install-talisman.sh
```

```t
# Install to a single project
cd my-git-project
# as a pre-push hook
~/install-talisman.sh
# or as a pre-commit hook
~/install-talisman.sh pre-commit
```

To skip a file add  .talismanrc file and add file content to it which you dont want it to scan next time

once you remove the file again git add and git commit and git push

# Pit mutation

added plugin

modified jenkins stage and modified test case

# Sonarqube

docker run -d --name sonarqube -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true -p 9000:9000 sonarqube:latest

default username/pass admin/admin i have changed it to general

configured project and added stage in jenkins file

check sonarQube-jenkins-scanner plugin and its documentation to configure sonarqube in confiure system
https://docs.sonarsource.com/sonarqube/latest/analyzing-source-code/scanners/jenkins-extension-sonarqube/
to create token go to sonarqube ui --> my account --> security --> create token
and add webhook in sonarqube ui aswell http://34.28.94.32:30685/sonarqube-webhook/

commented un used imports to resolve code smells

docker restart sonarqube (if you restart your vm)

# Added dependency check
added plugin in pom.xml and added stage in jenkins
to check what other configurations https://jeremylong.github.io/DependencyCheck/dependency-check-maven/

OWASP-dependency-check-plugin is the plugin which we use in jenkins

update spring boot parent release version to solve vulnerability issue found from dependency check plugin

# Trivy
https://github.com/aquasecurity/trivy

docker run --rm -v $HOME/Library/Caches:/root/.cache/ aquasec/trivy image python:3.4-alpine

docker run --rm -v $HOME/Library/Caches:/root/.cache/ aquasec/trivy --severity SEVERE --exit-code 1 image python:3.4-alpine

echo $? to see exit codes





