#!/bin/bash
which kubectl
if [ $? -ne 0 ]; then
   echo "Please make sure your are running this script on Kubernetes platform"
   exit
fi
##########################################
# build one image and contianner for developer
##########################################


#######################################
echo " start to build and configure Jenkins server ..."
#build Jenkins Server
#######################################
docker build -t jenkinsci/blueocean -f Dockerfile_jenkins

kubectl create -f deployment_jenkins.yaml
kubectl create -f deployJenkinsService.yaml

echo "Please wailt a few minutes to be ready ..."
sleep 10
node=`kubectl get pods -o wide  | grep jenkinstest1 | awk '{print $7}'`
ssh $node "groupadd -g 1000 jenkins && adduser -u 1000 -g 1000 jenkins"
ssh $node  "chown jenkins:jenkins -R /home/jenkins_home"

###################################
# Build package and create Jenkins file
###################################
# 1, install plugin for Jenkins and test the connection
ipaddr=`kubectl get pods  -o wide | grep jenkinstest1 | awk '{print $6}'`
host=`kubectl get pods  -o wide | grep jenkinstest1 | awk '{print $1}'
pwd=`kubectl exec -it ${host} cat /var/jenkins_home/secrets/initialAdminPassword`
mkdir jcli && cd jcli
wget http://${ipaddr}/jnlpJars/jenkins-cli.jar
# tar xzv jenkins-cli.jar
java -jar jenkins-cli.jar -s http://${ipaddr}:8080 -auth admin:88919ef0f67e44bba467cb43f3fb0574 install-plugin gradle
# such as, java -jar jenkins-cli.jar -s http://10.44.0.1:8080 -auth admin:88919ef0f67e44bba467cb43f3fb0574 install-plugin gradle

2, create the pipline by hand and use the file, Jenkinsfile to do the build automatically.
file name: Jenkinsfile
git url: https://github.com/DerexFan/boxer

3, deploy package.
###############################
#Deploy package by ansible in file Jenkinsfile
###############################
echo "one image shoud be created and updated into image server, so just run command to deploy it.


####################################
# run the developer environment
# developer can code on each node of cluster
# run contianner to build package
cd dev && bash build.sh




