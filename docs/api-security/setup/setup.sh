#!/bin/bash

# Inputs: $TRIAL_JWT 
# Outputs: $ARGO_PWD

/usr/local/bin/k3s-uninstall.sh

systemctl disable udf-setup

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik --egress-selector-mode=disabled --bind-address 10.1.1.5 --kube-apiserver-arg=feature-gates=LegacyServiceAccountTokenNoAutoGeneration=false" INSTALL_K3S_VERSION=v1.25.12+k3s1 sh -s -

kubectl -n kube-system create serviceaccount udf-sa
kubectl create clusterrolebinding udf-sa-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:udf-sa

# create kubeconfig
/root/modern_app_jumpstart_workshop/setup/scripts/gen_kubeconfig.sh

PWD=/root/modern_app_jumpstart_workshop_infra

rm -rf $PWD

git clone https://github.com/f5devcentral/modern_app_jumpstart_workshop_infra.git $PWD


# get latest version of scripts
cd $PWD

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

cat > argocd-nodeport.yaml <<-EOF
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/component: server
    app.kubernetes.io/name: argocd-server
    app.kubernetes.io/part-of: argocd
  name: argocd-server-nodeport
  namespace: argocd
spec:
  ports:
    - name: http
      port: 80
      protocol: TCP
      targetPort: 8080
      nodePort: 30007
    - name: https
      port: 443
      protocol: TCP
      targetPort: 8080
      nodePort: 30008
  selector:
    app.kubernetes.io/name: argocd-server
  sessionAffinity: None
  type: NodePort
EOF

kubectl apply -f argocd-nodeport.yaml

# Create nginx-ingress namespace
kubectl create namespace nginx-ingress

# create container registry secret
kubectl create secret docker-registry regcred --docker-server=private-registry.nginx.com --docker-username=$TRIAL_JWT --docker-password=none -n nginx-ingress

cat > manifests/nginx-ingress-subchart.yaml <<-EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: nginx-plus-ingress
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    path: charts/nginx-plus-ingress-official-private-registry
    repoURL: https://github.com/f5devcentral/modern_app_jumpstart_workshop_infra.git
    targetRevision: HEAD
  destination:
    namespace: nginx-ingress
    server: https://kubernetes.default.svc
  syncPolicy:
    automated:
      selfHeal: true
      prune: true
    syncOptions:
      - CreateNamespace=true
      - ApplyOutOfSyncOnly=true
EOF

kubectl apply -f manifests/nginx-ingress-subchart.yaml

cat > manifests/prometheus-subchart.yaml <<-EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: prometheus
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    path: charts/prometheus
    repoURL: https://github.com/f5devcentral/modern_app_jumpstart_workshop_infra.git
    targetRevision: HEAD
  destination:
    namespace: monitoring
    server: https://kubernetes.default.svc
  syncPolicy:
    automated:
      selfHeal: true
      prune: true
    syncOptions:
      - CreateNamespace=true
      - ApplyOutOfSyncOnly=true
EOF

kubectl apply -f manifests/prometheus-subchart.yaml

cat > manifests/grafana-subchart.yaml <<-EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: grafana
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    path: charts/grafana
    repoURL: https://github.com/f5devcentral/modern_app_jumpstart_workshop_infra.git
    targetRevision: HEAD
  destination:
    namespace: monitoring
    server: https://kubernetes.default.svc
  syncPolicy:
    automated:
      selfHeal: true
      prune: true
    syncOptions:
      - CreateNamespace=true
      - ApplyOutOfSyncOnly=true
EOF

kubectl apply -f manifests/grafana-subchart.yaml

# Add TLS certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/brewz-selfsigned.key -out /etc/ssl/certs/brewz-selfsigned.crt -subj "/C=US/ST=WA/L=Seattle/O=F5/OU=Brewz/CN=brewz.f5demo.com/emailAddress=brewz@f5demo.com"

sudo kubectl create secret tls brewz-tls --key=/etc/ssl/private/brewz-selfsigned.key --cert=/etc/ssl/certs/brewz-selfsigned.crt
