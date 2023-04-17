#!/bin/bash

# Install setup tools

sudo apt-get -y update
sudo apt -y upgrade

sudo apt-get install -y net-tools

# Node-RED
sudo apt-get install -y nodejs
sudo apt-get install -y npm
sudo npm install -g --unsafe-perm node-red

# PostgresDB
sudo apt install wget ca-certificates
wget -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
sudo apt update
apt install -y postgresql postgresql-contrib