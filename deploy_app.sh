#!/bin/sh

# Check if kubectl is installed
if ! [ -x "$(command -v kubectl)" ]; then
  echo 'Error: Kubectl is not installed.' >&2
  exit 1
fi

# Check if kubectl is installed
if ! [ -x "$(command -v git)" ]; then
  echo 'Error: Git is not installed.' >&2
  exit 1
fi

# Get Application Files
git clone https://github.com/dockersamples/example-voting-app.git
cd example-voting-app

#Create namespace for application
kubectl create namespace vote

# Create others kuberntes resourcers
kubectl create -f k8s-specifications/

# Deploy aws nlb to acess applicationkubectl get clusterroles
kubectl create -f ../k8s-aws-nlb
