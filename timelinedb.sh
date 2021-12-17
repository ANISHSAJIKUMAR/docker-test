#!/bin/bash
sudo su -
set -x
sudo apt-get update -y 
sudo apt-get upgrade -y 

#Installing docker 
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update -y
apt-cache policy docker-ce
sudo apt install docker-ce
sudo systemctl start docker
sudo systemctl enable docker



#Installing docker-compose
sudo apt-get install docker-compose -y 
sudo apt-get install git -y

mkdir docker_test
cd docker_test 
git clone https://github.com/ANISHSAJIKUMAR/docker_project2.git
cd docker_project2
docker-compose up -d


#psql -d a -U postgres -W
#https://github.com/khezen/compose-postgres
