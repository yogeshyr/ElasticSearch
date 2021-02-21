#!/bin/bash

sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get install -y default-jre

#Download and install the public signing key
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

#Save the repository definition
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list

#install the Elasticsearch Debian package 
sudo apt-get update -y && sudo apt-get install elasticsearch

#download and install Debian package for Elasticsearch
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.11.1-amd64.deb
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.11.1-amd64.deb.sha512
shasum -a 512 -c elasticsearch-7.11.1-amd64.deb.sha512 
sudo dpkg -i elasticsearch-7.11.1-amd64.deb

#updating elasticsearch.yml to enable secure authentication and communication
sudo tee -a  /etc/elasticsearch/elasticsearch.yml <<EOT
xpack.security.enabled: true
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.verification_mode: certificate
xpack.security.transport.ssl.keystore.path: certs/elastic-stack-ca.p12
xpack.security.transport.ssl.truststore.path: certs/elastic-stack-ca.p12
action.auto_create_index: .monitoring*,.watches,.triggered_watches,.watcher-history*,.ml*
EOT

#creation of certificates
cd /usr/share/elasticsearch
sudo bin/elasticsearch-certutil ca --pass "" --out elastic-stack-ca.p12
sudo mkdir /etc/elasticsearch/certs
sudo cp /usr/share/elasticsearch/elastic-stack-ca.p12 /etc/elasticsearch/certs/.
chmod 777 -R /etc/elasticsearch/certs

#configure Elasticsearch to start automatically 
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service

#Start elasticsearch
sudo systemctl start elasticsearch.service
sudo systemctl enable elasticsearch.service