#!/bin/bash

KUBECONFIG=/etc/rancher/k3s/config-udf.yaml

# Get the UDF Access Method
HOST=`curl -s metadata.udf/deployment | jq '.deployment.components[] | select(.name == "k3s") | .accessMethods.https[] | select(.label == "K3s API") | .host' -r`

# Get the UDF Access Method's CA
CA=`openssl s_client -connect $HOST:443 2>&1 </dev/null | sed -ne '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p'|base64 -w 0`

# Ensure the Kubernetes API is up
while ! kubectl get po
do
    echo waiting for kube api to be up...
    sleep 10
done

# Add the UDF K8s API 
kubectl config --kubeconfig=$KUBECONFIG set-cluster udf --server=https://$HOST:443 2>&1 >/dev/null
kubectl config --kubeconfig=$KUBECONFIG set clusters.udf.certificate-authority-data $CA 2>&1 >/dev/null

# set the token
TOKENNAME=`kubectl -n kube-system get serviceaccount/udf-sa -o jsonpath='{.secrets[0].name}'`

TOKEN=`kubectl -n kube-system get secret $TOKENNAME -o jsonpath='{.data.token}' | base64 --decode`

kubectl config --kubeconfig=$KUBECONFIG set-credentials udf-sa --token=$TOKEN 2>&1 >/dev/null

# Set context
kubectl config --kubeconfig=$KUBECONFIG set-context udf --cluster=udf --namespace=default --user=udf-sa 2>&1 >/dev/null

# Set current context
kubectl config --kubeconfig=$KUBECONFIG set current-context udf 2>&1 >/dev/null

# Copy kubeconfig to NGINX content root
cp $KUBECONFIG /usr/share/nginx/html/
chmod 744 /usr/share/nginx/html/config-udf.yaml
