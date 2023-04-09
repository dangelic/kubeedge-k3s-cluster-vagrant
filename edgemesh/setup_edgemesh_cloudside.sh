#!/bin/bash

CLOUDSIDE_IP=""
# NOTE: Set RELAY_NODE as the Cloudside Node name (e.g. kube-cloudcore)
RELAY_NODE_NAME=""

# Parse args
while [ $# -gt 0 ]; do
  case "$1" in
    --cloudside-ip=*)
      CLOUDSIDE_IP="${1#*=}"
      ;;
    --relay-node-name=*)
      RELAY_NODE_NAME="${1#*=}"
      ;;
    *)
      echo "Error: Invalid argument: $1"
      exit 1
      ;;
  esac
  shift
done

# NOTE: With the keadm init command in bootstrap_cloudside.sh, the basic adjustment for EdgeMesh for Cloudside is made
# REF: https://edgemesh.netlify.app/guide/edge-kube-api.html#quick-start

sudo su

# Get HELM
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Generate PSK-Cypher and save it in .txt
# REF: https://edgemesh.netlify.app/guide/security.html#generate-psk-cipher
openssl rand -base64 32 >> psk_cypher.txt
PSK=$(cat psk_cypher.txt)

# Install EdgeMesh via HELM
helm install edgemesh --namespace kubeedge \
--set agent.psk=$PSK \
--set agent.relayNodes[0].nodeName=$RELAY_NODE_NAME,agent.relayNodes[0].advertiseAddress="{$CLOUDSIDE_IP}" \
https://raw.githubusercontent.com/kubeedge/edgemesh/main/build/helm/edgemesh.tgz


# Install EdgeMesh-Gateway manual
# NOTE: Change the files 04-... and 05-... in ./manifests according to the needs of the cluster!
# NOTE: Change PSK, Relay Node Name and IP in files!
# REF: https://edgemesh.netlify.app/guide/edge-gateway.html#deploy

kubectl apply -f manifests

# Create HTTP-Gateway
# REF: https://edgemesh.netlify.app/guide/edge-gateway.html#http-gateway
kubectl apply -f examples/hostname-lb-random-gateway.yaml
