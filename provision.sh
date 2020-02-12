#!/bin/sh

# Check if terraform is installed
if ! [ -x "$(command -v terraform)" ]; then
  echo 'Error: Terraform is not installed.' >&2
  exit 1
fi

# Check if kops is installed
if ! [ -x "$(command -v kops)" ]; then
  echo 'Error: Kops is not installed.' >&2
  exit 1
fi

#Default Values
DOMAIN='aws.infini.net.br'
CLUSTER_NAME='getup'

# Get arguments
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    --skip_tf)
    ignore_tf=True
    shift # past argument
    shift # past value
    ;;
    -d|--domain)
    DOMAIN="$2"
    shift # past argument
    shift # past value
    ;;
    -c|--cluster_name)
    CLUSTER_NAME="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters
 

if [ $ignore_tf ]; then
    echo "Skipping terraform apply"
else
    echo "Run terraform to setup pre-reqs for kops deployment on AWS"
    echo "Obs. You domain must be valid and configured for NS of AWS created"
    terraform init
    if [ $(terraform workspace list |grep ${CLUSTER_NAME} |wc -l) -eq 0 ]; then
        terraform workspace new ${CLUSTER_NAME}
    else
        terraform workspace select ${CLUSTER_NAME}
    fi
    terraform apply -var domain=${DOMAIN} -var cluster_name=${CLUSTER_NAME} -auto-approve
    
fi

echo "Export state config for variable KOPS_STATE_STORE"
export KOPS_STATE_STORE='s3://'$(terraform output kops_state_bucket)

if [ $(kops get cluster|grep $(terraform output cluster_domain) |wc -l) -eq 0 ]; then
    echo "Create cluster with kops at zones us-east-1a,us-east-1b,us-east-1c and intance sizer t3.micro with only 1 master and node for demo propose"
    kops create cluster --zones=us-east-1a,us-east-1b,us-east-1c $(terraform output cluster_domain) --master-size=t3.micro --node-size=t3.micro --yes --node-count=1
fi

while :
do
  echo "Waiting for cluster to finish..."
  kops validate cluster
  status=$?
  echo $status
  if [ $status -eq 0 ]; then
    break;
  fi
  echo "Sleept for 10 seconds"
  sleep 10

done