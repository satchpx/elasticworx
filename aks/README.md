# Elasticsearch-px test on AKS

## Pre-requisites
1. Azure account
2. Azure application https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app
3. Register application with Azure AD https://docs.microsoft.com/en-us/rest/api/azure/#register-your-client-application-with-azure-ad
4. Note down the `Application ID`, `Tenant ID`, `Object ID` and `Application password`. This will be used in later steps

## Before you begin
```
git clone https://github.com/satchpx/elasticworx
cd elasticworx/aks
touch .creds.env
```

Add the following key-value pairs in `.creds.env`
```
APPID='<Azure application ID>'
TENANTID='<Tenant ID>'
OBJECTID='<Object ID>'
APPPW='<Application password>'
```

## Deploy AKS cluster

```
#./deploy.sh -g sathya-px-es -r eastus2 -c sathya-px-es1 -n 6 -s 1000 -d UltraSSD_LRS
# The above is blocked on enabling UltraSSD in US East 2 for the subscription ID
# For now use Standard SSD
./deploy.sh -g sathya-px-es -r eastus2 -c sathya-px-es1 -n 6 -s 1024 -d Premium_LRS
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

### Create the required storageClasses
```
kubectl apply -f manifests/portworx-storageclasses.yaml
```

### Deploy elasticsearch helm chart
```
helm install --name elasticsearch-master --values manifests/es-master-values-px-rf3.yaml ../helm-charts/elasticsearch
helm install --name elasticsearch-data --values manifests/es-client-values-px-rf3.yaml ../helm-charts/elasticsearch
helm install --name kibana --values manifests/kibana-values.yaml ../helm-charts/kibana
```

### Create a service for kibana to expose it outside the kubernetes cluster
* NOTE: this is only for on-prem, skip this for cloud
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

### Install Elasticsearch Exporter
```
helm install --name elasticsearch-exporter ../helm-charts/elasticsearch-exporter --set es.uri=http://elasticsearch-master.default:9200
```

### Update the exporter service to have it scraped by prometheus
```
kubectl edit svc elasticsearch-exporter
```
....and add the following annotation under metadata:
```
apiVersion: v1
kind: Service
metadata:
  annotations:
    prometheus.io/scrape: "true"
```


### Install prometheus and grafana for monitoring
```
git clone https://github.com/satchpx/prom-helm.git
cd prom-helm/
helm install --name prometheus --namespace monitoring prometheus --set server.persistentVolume.storageClass=px-db-rf1-sc,server.shedulerName=stork
helm install --name grafana --namespace monitoring grafana --set persistence.enabled=true,persistence.storageClassName=px-db-rf1-sc,schedulerName=stork
```

### Expose loadbalancer service for kibana and grafana
```
kubectl apply -f manifests/kibana-lb.yaml
kubectl apply -f manifests/grafana-lb.yaml
```

### Deploy elasticsearch data generator
```
kubectl apply -f ../es-test/es-datagen.yaml
```
