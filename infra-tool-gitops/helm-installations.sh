#!/bin/bash

# Kube-Prometheus-Stack
echo "Installing Prometheus..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update prometheus-community
helm install prometheus \
  prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  --version 68.1.0


# AWS Load Balancer Controller
echo "Installing AWS Load Balancer Controller..."
helm repo add eks https://aws.github.io/eks-charts
helm repo update eks
helm install aws-load-balancer-controller \
  eks/aws-load-balancer-controller \
  --set clusterName=dev-eks \
  -n kube-system \
  --set serviceMonitor.enabled=true \
  --set serviceMonitor.additionalLabels.release=prometheus \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller-sa \
  --version 1.11.0


# External DNS
echo "Installing External DNS..."
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm repo update external-dns
helm install external-dns \
  -n external-dns \
  external-dns/external-dns \
  --set provider=aws \
  --set txtOwnerId=external-dns \
  --set policy=sync \ 
  --set serviceMonitor.enabled=true \
  --set serviceMonitor.additionalLabels.release=prometheus \
  --set serviceAccount.create=false \
  --set serviceAccount.name=external-dns-sa \
  --version 1.15.0


# KuebeArmor
echo "Installing KuebeArmor..."
helm repo add kubearmor https://kubearmor.github.io/charts
helm repo update kubearmor
helm install kubearmor \
  -n kubearmor --create-namespace \
   kubearmor/kubearmor \
   --version 1.4.6


# Metrics-Server
echo "Installing Metrics-Server..."
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update metrics-server
helm install metrics-server \
  -n metrics-server --create-namespace \
  metrics-server/metrics-server \
  --set serviceMonitor.enabled=true \
  --set serviceMonitor.additionalLabels.release=prometheus \
  --version 3.12.2


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
  --set serviceAccount.name=external-secret-sa \
  --version 0.12.1

# Gatekeeper (Policy as Code)
echo "Installing OPA Gatekeeper..."
helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
helm repo update gatekeeper
helm install gatekeeper \
  -n gatekeeper --create-namespace \
  gatekeeper/gatekeeper \
  --version 3.19.0-beta.1
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
  --version 8.5.1


# Kibana (Ensure you use the same version with ElasticSearch)
echo "Installing Kibana..."
helm install kibana \
  -n efk \
  elastic/kibana \
  --version 8.5.1




 

