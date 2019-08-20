# Elasticworx on EKS
Running Elasticsearch backed by Portworx on EKS

## Deploy EKS Cluster
```
eksctl create cluster \
--name ${NAME} \
--region ${REGION} \
--zones ${ZONES} \
--nodegroup-name ${NODEGROUP_NAME} \
--node-type ${NODE_TYPE} \
--nodes ${NODE_COUNT} \
--nodes-min ${NODE_COUNT_MAX} \
--nodes-max ${NODE_COUNT_MIN} \
--node-ami ${AMI} \
--ssh-public-key ${KEY}
```
Note: In this experiment, I am deploying a 3-node EKS cluster running across 3 availability zones.

## Install Portworx
### Before you start
```
Provide the EC2 instance permissions to create/attach/detach/delete EBS volumes. This is documented [here](https://docs.portworx.com/portworx-install-with-kubernetes/cloud/aws/aws-eks/#prepare)
```

### Install Portworx using cloud-drives
```
kubectl apply -f 'https://install.portworx.com/?mc=false&kbver=1.13.8&b=true&s=%22type%3Dgp2%2Csize%3D150%22&md=type%3Dgp2%2Csize%3D150&c=px-cluster-402edc71-118a-417c-bfdb-6822a6443b4a&eks=true&stork=true&lh=true&st=k8s'
```

## Install Elasticsearch