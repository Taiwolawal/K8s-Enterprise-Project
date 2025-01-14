#!/bin/bash

# Kube-Prometheus-Stack
echo "Installing Prometheus..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update prometheus-community
helm install prometheus \
  prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  --version 26.1.0


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
  --set serviceAccount.name=aws-load-balancer-controller \
  --version 1.11.0


# External DNS
echo "Installing External DNS..."
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm repo update external-dns
helm install external-dns \
  -n external-dns \
  external-dns/external-dns \
  --set provider=aws \
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
  --version 0.12.1

