#!/usr/bin/env bash

# add repository key
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
echo '========== JENKINS REPO KEY ADDED =========='

# add debian package to sources.list
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
echo '========== JENKINS DEBIAN PACKAGE ADDED =========='

# update package list
sudo apt update

# install jenkins and java
sudo apt install default-jre jenkins -y
echo '========== JAVA + JENKINS INSTALLED =========='

# start jenkins
sudo systemctl start jenkins
echo '========== JENKINS STARTED =========='

# print jenkins status
sudo systemctl status jenkins

# allow jenkins through firewall
sudo ufw allow 8080
echo '========== UFW FIREWALL UPDATED =========='

# print ufw status to view firewall change
sudo ufw status

# output url to visit
echo "Visit http://$(curl --silent icanhazip.com):8080 to setup Jenkins."

# output admin password
echo "Administrator Password: $(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)"
