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
Provide the EC2 instance permissions to create/attach/detach/delete EBS volumes. This is documented [here](https://docs.portworx.com/portworx-install-with-kubernetes/cloud/aws/aws-eks/#prepare)


### Install Portworx using cloud-drives
```
kubectl apply -f 'https://install.portworx.com/?mc=false&kbver=1.13.8&b=true&s=%22type%3Dgp2%2Csize%3D150%22&md=type%3Dgp2%2Csize%3D150&c=px-cluster-402edc71-118a-417c-bfdb-6822a6443b4a&eks=true&stork=true&lh=true&st=k8s'
```

## Install Elasticsearch
### Install helm
```
https://github.com/helm/helm/blob/master/docs/install.md
```

### Initialize helm
```
helm  init
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
```

### Deploy elasticsearch helm chart
```
helm install --name elasticsearch-master --values manifests/es-master-values-gp2.yaml ../helm-charts/elasticsearch
helm install --name elasticsearch-client --values manifests/es-client-values-gp2.yaml ../helm-charts/elasticsearch
helm install --name kibana --values manifests/kibana-values.yaml ../helm-charts/kibana
```

### Create a service for kibana to expose it outside the kubernetes cluster
```
apiVersion: v1
kind: Service
metadata:
  name: kibana-np
  labels:
    app: kibana
spec:
  type: NodePort
  ports:
    - port: 5601
  selector:
    app: kibana
```