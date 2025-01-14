
# Kube-Prometheus-Stack
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace


# AWS Load Balancer Controller
helm repo add eks https://aws.github.io/eks-charts
helm install \
  aws-load-balancer-controller \
  eks/aws-load-balancer-controller \
  --set clusterName=dev-eks \
  -n kube-system \
  --set serviceMonitor.enabled=true \
  --set serviceMonitor.additionalLabels.release=prometheus \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller 
  --version 1.11.0


# External DNS
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm show values external-dns/external-dns --version 1.15.0  > external-dns.yaml

helm install external-dns \
  -n external-dns
  external-dns/external-dns \
  --set provider=aws \
  --set serviceMonitor.enabled=true \
  --set serviceMonitor.additionalLabels.release=prometheus \
  --set serviceAccount.create=false \
  --set serviceAccount.name=external-dns-sa 
  --version 1.15.0