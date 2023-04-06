#!/bin/bash

CLOUDSIDE_IP=""

# Parse arg
while [ $# -gt 0 ]; do
  case "$1" in
    --cloudside-ip=*)
      CLOUDSIDE_IP="${1#*=}"
      ;;
    *)
      echo "Error: Invalid argument: $1"
      exit 1
      ;;
  esac
  shift
done

# Disable firewall for testing
sudo ufw disable

sudo apt-get update

# -- Setup K3s Cluster in v1.23.5

# Get installer tool for K3s and run it
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="v1.23.5+k3s1" K3S_TOKEN="leipzig" sh -

# Make kubectl available for non-root user
sudo chown $(id -u):$(id -g) /etc/rancher/k3s/k3s.yaml

# Copy K3s cluster-config "k3s.yaml" and rename it as "config" so Keadm installer can locate it without extra args
mkdir -p $HOME/.kube
sudo cp -i /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# -- Setup KubeEdge in v1.13.0

# Get Keadm as installer tool for KubeEdge
wget https://github.com/kubeedge/kubeedge/releases/download/v1.13.0/keadm-v1.13.0-linux-amd64.tar.gz
tar -zxvf keadm-v1.13.0-linux-amd64.tar.gz
cp keadm-v1.13.0-linux-amd64/keadm/keadm /usr/local/bin/keadm

# Initialize Cloudcore with Keadm
keadm init --advertise-address=$CLOUDSIDE_IP --profile version=v1.13.0 --kube-config=/root/.kube/config

echo "Sleep 20..."
sleep 20

keadm gettoken > ketoken.txt
echo "*** KubeEdge token ***"
cat ketoken.txt

# -- Setup EdgeMesh

# Refer: https://edgemesh.netlify.app/guide/#manual-install
# Test: https://edgemesh.netlify.app/guide/test-case.html#cross-edge-cloud
git clone https://github.com/kubeedge/edgemesh.git
kubectl apply -f edgemesh/build/crds/istio/
kubectl apply -f edgemesh/build/agent/resources/

# -- Setup tunnel for Edgeside port
export CLOUDCOREIPS=$CLOUDSIDE_IP
iptables -t nat -A OUTPUT -p tcp --dport 10350 -j DNAT --to $CLOUDCOREIPS:10003

# -- Setup MQTT-Client Cloudside as Middleware in edge-to-edge (and to cloud) communication

sudo add-apt-repository -y ppa:mosquitto-dev/mosquitto-ppa
sudo apt install -y mosquitto mosquitto-clients

# Set bind-adress to public ip instead of localhost
sudo echo "bind_address $CLOUDSIDE_IP" >> /etc/mosquitto/mosquitto.conf
# Allow traffic from Edge Nodes without auth
sudo echo "allow_anonymous true" >> /etc/mosquitto/mosquitto.conf
sudo systemctl restart mosquitto

# Add a topic for edge-to-edge (and to cloud) communication
mosquitto_sub -h $CLOUDSIDE_IP -p 1883 -t edge-to-edge

echo "\nScript: done."
