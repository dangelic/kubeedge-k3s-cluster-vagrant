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
# NOTE: A restart might be necessary
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

# Get HELM
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# -- Setup KubeEdge in v1.13.0

# Get Keadm as installer tool for KubeEdge
wget https://github.com/kubeedge/kubeedge/releases/download/v1.13.0/keadm-v1.13.0-linux-amd64.tar.gz
tar -zxvf keadm-v1.13.0-linux-amd64.tar.gz
cp keadm-v1.13.0-linux-amd64/keadm/keadm /usr/local/bin/keadm

# Initialize Cloudcore with Keadm
# NOTE: dynamicController.enable=true is important for EdgeMesh enablement
# REF: https://edgemesh.netlify.app/guide/edge-kube-api.html#quick-start
keadm init --advertise-address=$CLOUDSIDE_IP --profile version=v1.13.0 --kube-config=/root/.kube/config --set cloudCore.modules.dynamicController.enable=true

echo "Sleep 20..."
sleep 20

# Get the token to join Edgecore
keadm gettoken > ketoken.txt
echo "*** KubeEdge token ***"
cat ketoken.txt

# NOTE: EdgeMesh setup is outsourced in /edgemesh dir
# # -- Setup EdgeMesh

# # Refer: https://edgemesh.netlify.app/guide/#manual-install
# # Test: https://edgemesh.netlify.app/guide/test-case.html#cross-edge-cloud
# git clone https://github.com/kubeedge/edgemesh.git
# kubectl apply -f edgemesh/build/crds/istio/
# kubectl apply -f edgemesh/build/agent/resources/

# -- Setup tunnel for Edgeside port
export CLOUDCOREIPS=$CLOUDSIDE_IP
iptables -t nat -A OUTPUT -p tcp --dport 10350 -j DNAT --to $CLOUDCOREIPS:10003

echo "\nScript: done."
