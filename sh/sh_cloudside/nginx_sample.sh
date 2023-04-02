#!/bin/bash

# Refer: https://edgemesh.netlify.app/guide/#manual-install
# Test: https://edgemesh.netlify.app/guide/test-case.html#cross-edge-cloud
git clone https://github.com/kubeedge/edgemesh.git
kubectl apply -f edgemesh/build/crds/istio/
kubectl apply -f edgemesh/build/agent/resources/
kubectl get all -n kubeedge -o wide

# Simple Test with nginx:
kubectl apply -f https://k8s.io/examples/application/deployment.yaml
kubectl expose deployment nginx-deployment
kubectl get deployments
# curl <the CIP-Service IP>:80