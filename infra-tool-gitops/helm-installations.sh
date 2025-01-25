#!/bin/bash

# Variables
CLUSTER_NAME="dev-eks"

# Helm Versions
PROMETHEUS_COMMUNITY_VERSION="68.1.0"
ALB_CONTROLLER_VERSION="1.11.0"
EXTERNAL_DNS_VERSION="1.15.0"
KUBEARMOR_VERSION="1.4.6"
METRICS_SERVER_VERSION="3.12.2"
EXTERNAL_SECRET_VERSION="0.12.1"
OPA_GATEKEEPER_VERSION="3.19.0-beta.1"
ELASTIC_SEARCH_VERSION="8.5.1"
KIBANA_VERSION="8.5.1"
VELERO_VERSION="8.3.0"

# Service Accounts
SERVICE_ACCOUNT_ALB_CONTROLLER="aws-load-balancer-controller-sa"
SERVICE_ACCOUNT_EXTERNAL_DNS="external-dns-sa"
SERVICE_ACCOUNT_EXTERNAL_SECRET="external-secret-sa"
SERVICE_ACCOUNT_VELERO="velero-sa"

# AWS
PROVIDER="aws"
VELERO_BUCKET_NAME="velero-k8s-backup-bucket-azef11"
REGION="us-east-1"
VELERO_PLUGIN_IMAGE="velero/velero-plugin-for-aws:v1.10.0"


# Kube-Prometheus-Stack
echo "Installing Prometheus..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update prometheus-community
helm install prometheus \
  prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  --version ${PROMETHEUS_COMMUNITY_VERSION}


# AWS Load Balancer Controller
echo "Installing AWS Load Balancer Controller..."
helm repo add eks https://aws.github.io/eks-charts
helm repo update eks
helm install aws-load-balancer-controller \
  eks/aws-load-balancer-controller \
  --set clusterName=${CLUSTER_NAME} \
  -n kube-system \
  --set serviceMonitor.enabled=true \
  --set serviceMonitor.additionalLabels.release=prometheus \
  --set serviceAccount.create=false \
  --set serviceAccount.name=${SERVICE_ACCOUNT_ALB_CONTROLLER} \
  --version ${ALB_CONTROLLER_VERSION}


# External DNS
echo "Installing External DNS..."
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm repo update external-dns
helm install external-dns \
  -n external-dns \
  external-dns/external-dns \
  --set provider=${PROVIDER} \
  --set txtOwnerId=external-dns \
  --set policy=sync \ 
  --set serviceMonitor.enabled=true \
  --set serviceMonitor.additionalLabels.release=prometheus \
  --set serviceAccount.create=false \
  --set serviceAccount.name=${SERVICE_ACCOUNT_EXTERNAL_DNS} \
  --version ${EXTERNAL_DNS_VERSION}


# KuebeArmor
echo "Installing KuebeArmor..."
helm repo add kubearmor https://kubearmor.github.io/charts
helm repo update kubearmor
helm install kubearmor \
  -n kubearmor --create-namespace \
   kubearmor/kubearmor \
   --version ${KUBEARMOR_VERSION}


# Metrics-Server
echo "Installing Metrics-Server..."
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update metrics-server
helm install metrics-server \
  -n metrics-server --create-namespace \
  metrics-server/metrics-server \
  --set serviceMonitor.enabled=true \
  --set serviceMonitor.additionalLabels.release=prometheus \
  --version ${METRICS_SERVER_VERSION}


# External Secrets
echo "Installing External Secrets..."
helm repo add external-secrets https://charts.external-secrets.io
helm repo update external-secrets 
helm install external-secrets  \
  -n external-secrets --create-namespace \
  external-secrets/external-secrets \
  --set serviceMonitor.enabled=true \
  --set serviceMonitor.additionalLabels.release=prometheus \
  --set serviceAccount.create=false \
  --set serviceAccount.name=${SERVICE_ACCOUNT_EXTERNAL_SECRET} \
  --version ${EXTERNAL_SECRET_VERSION}

# Gatekeeper (Policy as Code)
echo "Installing OPA Gatekeeper..."
helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
helm repo update gatekeeper
helm install gatekeeper \
  -n gatekeeper --create-namespace \
  gatekeeper/gatekeeper \
  --version ${OPA_GATEKEEPER_VERSION}
# NOTE: Ensure you run constraintemplate before running contraints.


# ElasticSearch (Ensure you have deployed storage class)
echo "Installing ElasticSearch..."
helm repo add elastic https://helm.elastic.co
helm repo update elastic
helm install elasticsearch \
  -n efk --create-namespace \
  elastic/elasticsearch \
  --set replicas=3 \
  --set volumeClaimTemplate.storageClassName=ebs-gp3 \
  --set volumeClaimTemplate.resources.requests.storage=5Gi \
  --set persistence.labels.enabled=true \
  --set persistence.labels.customLabel=elasticsearch-pv \
  --version ${ELASTIC_SEARCH_VERSION}


# Kibana (Ensure you use the same version with ElasticSearch)
echo "Installing Kibana..."
helm install kibana \
  -n efk \
  elastic/kibana \
  --version ${KIBANA_VERSION}


# Velero (For Cluster Backup and Restore)
echo "Installing Velero..."
helm repo add velero https://charts.velero.io/
helm repo update velero
helm install velero \
  -n velero \
  velero/velero \
  --set serviceMonitor.enabled=true \
  --set serviceMonitor.additionalLabels.release=prometheus \
  --set initContainers[0].name=velero-plugin-for-aws \
  --set initContainers[0].image=${VELERO_PLUGIN_IMAGE} \
  --set initContainers[0].imagePullPolicy=IfNotPresent \
  --set initContainers[0].volumeMounts[0].mountPath=/target \
  --set initContainers[0].volumeMounts[0].name=plugins \
  --set configuration.backupStorageLocation[0].provider=${PROVIDER} \
  --set configuration.backupStorageLocation[0].bucket=${VELERO_BUCKET_NAME} \
  --set configuration.backupStorageLocation[0].config.region=${REGION} \
  --set configuration.volumeSnapshotLocation[0].provider=${PROVIDER} \
  --set configuration.volumeSnapshotLocation[0].config.region=${REGION} \
  --set serviceAccount.server.create=false \
  --set serviceAccount.server.name=${SERVICE_ACCOUNT_VELERO} \
  --set credentials.useSecret=false
  --version ${VELERO_VERSION}




 

