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

sudo -i

# -- Setup K3s Cluster in v1.22.5

# Get installer tool for K3s and run it
# Note: K3s installs traefik as CNI per default, so it needs to be disabled to provide a suiting CNI for this setup
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="v1.22.5+k3s1" K3S_TOKEN="leipzig" INSTALL_K3S_EXEC="--no-deploy traefik" sh -

# Copy K3s cluster-config "k3s.yaml" and rename it as "config" so Keadm installer can locate it without extra args
mkdir -p $HOME/.kube
sudo cp -i /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Calico as CNI
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/tigera-operator.yaml
curl https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/custom-resources.yaml -O
kubectl create -f custom-resources.yaml

# -- Setup KubeEdge in v1.12.1

# Get Keadm as installer tool for KubeEdge
wget https://github.com/kubeedge/kubeedge/releases/download/v1.12.1/keadm-v1.12.1-linux-amd64.tar.gz
tar -zxvf keadm-v1.12.1-linux-amd64.tar.gz
cp keadm-v1.12.1-linux-amd64/keadm/keadm /usr/local/bin/keadm

# Initialize Cloudcore with Keadm
keadm init --advertise-address=$CLOUDSIDE_IP --profile version=v1.12.1 --kube-config=/root/.kube/config

echo "Sleep 10..."
sleep 10

keadm gettoken > ketoken.txt
echo "*** KubeEdge token ***"
cat ketoken.txt

echo "Script: done."