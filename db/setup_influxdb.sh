#!/bin/bash

# Add InfluxDB repository to APT sources
sudo wget -qO- https://repos.influxdata.com/influxdb.key | sudo apt-key add -
echo "deb https://repos.influxdata.com/ubuntu bionic stable" | sudo tee /etc/apt/sources.list.d/influxdb.list

# Update package list
sudo apt update

# Install InfluxDB
sudo apt install influxdb -y

# Start InfluxDB service
sudo systemctl start influxdb

# Check the status of InfluxDB service
sudo systemctl status influxdb

# Enable InfluxDB service to start on system startup
sudo systemctl enable influxdb

# Output the URL where InfluxDB can be accessed
echo "InfluxDB is now installed and running. Access at http://localhost:8086"