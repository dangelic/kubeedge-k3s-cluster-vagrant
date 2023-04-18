#!/bin/bash

# Add Grafana repository to APT sources
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"

# Import the Grafana repository key
curl https://packages.grafana.com/gpg.key | sudo apt-key add -

# Update package list
sudo apt update

# Install Grafana
sudo apt install grafana -y

# Start Grafana server
sudo systemctl start grafana-server

# Check the status of Grafana server
sudo systemctl status grafana-server

# Enable Grafana server to start on system startup
sudo systemctl enable grafana-server

# Output the URL where Grafana can be accessed
echo "Grafana is now installed and running. Access at http://localhost:3000"
