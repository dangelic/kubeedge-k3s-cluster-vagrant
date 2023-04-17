#!/bin/bash

MQTT_SERVER_IP=""

# Parse arg
while [ $# -gt 0 ]; do
  case "$1" in
    --mqtt-server-ip=*)
      MQTT_SERVER_IP="${1#*=}"
      ;;
    *)
      echo "Error: Invalid argument: $1"
      exit 1
      ;;
  esac
  shift
done

# -- Setup MQTT Broker on Middleware Server

sudo add-apt-repository -y ppa:mosquitto-dev/mosquitto-ppa
sudo apt install -y mosquitto mosquitto-clients

# Set bind-adress to public ip instead of localhost
sudo echo "bind_address $MQTT_SERVER_IP" >> /etc/mosquitto/mosquitto.conf
# Allow traffic from Clients without auth
sudo echo "allow_anonymous true" >> /etc/mosquitto/mosquitto.conf
sudo systemctl restart mosquitto

# Add a topic for edge-to-edge (and to cloud) communication
TOPIC="sensor-stream-converted"
mosquitto_sub -h $MQTT_SERVER_IP -p 1883 -t $TOPIC