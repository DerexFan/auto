#!/bin/bash
which kubectl
if [ $? -ne 0 ]; then
   echo ""
   echo "Please make sure your are running this script on Kubernetes platform"
   eecho ""
   exit
fi
##########################################
# build one image and contianner for developer
##########################################


#######################################
echo " start to build and configure Jenkins server ..."
#build Jenkins Server
#######################################
#1, build image:
docker build -t jenkinsci/blueocean -f Dockerfile_jenkins .

#2, Enable the pod
kubectl create -f deployment_jenkins.yaml
kubectl create -f deployJenkinsService.yaml

echo "Please wailt a few seconds to be ready ..."
sleep 10
pod_status=`kubectl get pods  | grep jenkinstest1`
if echo "${pod_status}" | grep -iq "running"; then
   echo "the jenkins pod is running now"
else
  echo "seems the jenkins pod is not online, please wait ..."
  sleep 10
  pod_status=`kubectl get pods  | grep jenkinstest1`
  if echo "${pod_status}" | grep -iq "running"; then
     echo "the jenkins pod is running now"
  else
      echo "the jenkins pod is still NOT running, please check it ..."
      exit
  fi
fi

echo " check and/or create an account, jenkins "
if grep -qi jenkins /etc/passwd; then
    echo "the account is exist"
else
    echo "the account is NOT exist"
    groupadd -g 1000 jenkins && adduser -u 1000 -g 1000 jenkins"
    cat id_rsa.pub >> /home/jenkins/.ssh/authorized_keys
    echo "%jenkins        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
    
fi

kubeImageIP=`ifconfig enp0s3 | grep -w inet | awk '{print $2}'`
if [ -z "$kubeImageIP" ]; then
    echo "didn NOT get your IP of kubenet and Image server\, please input it in main script"
    exit
fi 
sed -i 's/10.0.2.5/${kubeImageIP}/gi' deployment_jenkins.yaml
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
echo "installing plugin ..."
java -jar jenkins-cli.jar -s http://${ipaddr}:8080 -auth admin:88919ef0f67e44bba467cb43f3fb0574 install-plugin gradle
sleep 3
# such as, java -jar jenkins-cli.jar -s http://10.44.0.1:8080 -auth admin:88919ef0f67e44bba467cb43f3fb0574 install-plugin gradle
echo "create pipline ..."
java -jar jenkins-cli.jar -s http://10.44.0.1:8080 -auth admin:88919ef0f67e44bba467cb43f3fb0574  create-job testcreatejob < config.xml
sleep 1
echo "build and pipline as well as upload the docker image"
java -jar jenkins-cli.jar -s http://10.44.0.1:8080 -auth admin:88919ef0f67e44bba467cb43f3fb0574  build testcreatejob
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




