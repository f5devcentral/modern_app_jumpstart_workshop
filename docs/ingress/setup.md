
# Setup
For this lab, you will start with a clean environment and build out your K3s environment.

## Uninstall K3s in UDF
```bash
/usr/local/bin/k3s-uninstall.sh
```

## Install K3s in UDF
```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--no-deploy traefik --bind-address 10.1.1.5" sh -s -
```

## Generate Service Account
To provide remote Access to the K8s API, best practice would be to generated a dedicated K8s Service Account:
```bash
kubectl -n kube-system create serviceaccount udf-sa
kubectl create clusterrolebinding udf-sa-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:udf-sa
TOKENNAME=`kubectl -n kube-system get serviceaccount/udf-sa -o jsonpath='{.secrets[0].name}'`
echo $TOKENNAME
TOKEN=`kubectl -n kube-system get secret $TOKENNAME -o jsonpath='{.data.token}' | base64 --decode`
echo $TOKEN
```

## Generate Local Kubeconfig
Now that we have K3s up and running and a dedicated service account for UDF we need to build a kubeconfig file so *kubectl* on your laptop knows how to access our cluster.

*Note:* the *kubectl config* command will produce warning about invalid configuration - this can be ingored since you are building the configuration

```bash
cd ~/.kube/
export KUBECONFIG=~/.kube/config-udf

# Get the UDF Access Method's CA - replace access method with your deployment data
openssl s_client -connect 44355f38-2543-42d2-aa52-e80d44c8a791.access.udf.f5.com:443 2>&1 </dev/null | sed -ne '/BEGIN CERT/,/END CERT/p' > udf.crt

# Verify the certificate 
openssl x509 -in udf.crt -text -noout

# Add the UDF K8s API 
kubectl config set-cluster udf --server=https://44355f38-2543-42d2-aa52-e80d44c8a791.access.udf.f5.com:443 --certificate-authority=udf.crt

# set the token
TOKEN=paste your token from the generate service account section
kubectl config set-credentials udf-sa --token=$TOKEN

# Set context
kubectl config set-context udf --cluster=udf --namespace=default --user=udf-sa

# Set current context
kubectl config set current-context udf

# Test kubeconfig
kubectl get nodes
```

Alternatively, you can run the following script on the UDF K3s server to generate a config-udf file you can copy to your laptop.  Save the script to gen_kubeconfig.sh
```bash
#!/bin/bash
KUBECONFIG=/etc/rancher/k3s/config-udf.yaml

HOST=`curl -s metadata.udf/deployment | jq '.deployment.components[] | select(.name == "k3s") | .accessMethods.https[] | select(.label == "K3s API") | .host' -r`

CA=`openssl s_client -connect $HOST:443 2>&1 </dev/null | sed -ne '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p'|base64 -w 0`

while ! kubectl get po
do
    echo waiting for kube api to be up...
    sleep 10
done

kubectl config --kubeconfig=$KUBECONFIG set-cluster udf --server=https://$HOST:443 2>&1 >/dev/null

kubectl config --kubeconfig=$KUBECONFIG set clusters.udf.certificate-authority-data $CA 2>&1 >/dev/null

TOKENNAME=`kubectl -n kube-system get serviceaccount/udf-sa -o jsonpath='{.secrets[0].name}'`

TOKEN=`kubectl -n kube-system get secret $TOKENNAME -o jsonpath='{.data.token}' | base64 --decode`

kubectl config --kubeconfig=$KUBECONFIG set-credentials udf-sa --token=$TOKEN 2>&1 >/dev/null

kubectl config --kubeconfig=$KUBECONFIG set-context udf --cluster=udf --namespace=default --user=udf-sa 2>&1 >/dev/null

kubectl config --kubeconfig=$KUBECONFIG set current-context udf 2>&1 >/dev/null

cat $KUBECONFIG
```

Now run the script and save the output to your laptop as your local kubeconfig file:
```bash
bash gen_kubeconfig.sh
```

## Install NGINX Plus Ingress
> Note: You'll need to pull the NGINX Plus Ingress Controller from your private registry

You can access the NGINX Ingress Controller documentation [here](https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-helm/)

```bash
kubectl create namespace nginx-ingress
kubectl create secret -n nginx-ingress docker-registry regcred \
  --docker-server=docker.io \
  --docker-username=${DOCKER_USERNAME} \ 
  --docker-password=${DOCKER_PAT} \ 
  --docker-email=${DOCKER_EMAIL}
helm repo add nginx-stable https://helm.nginx.com/stable

helm install nginx-plus-ingress -n nginx-ingress nginx-stable/nginx-ingress \
  --set controller.image.repository=docker.io/codygreen/nginx-plus-ingress \
  --set controller.image.tag=latest \
  --set controller.serviceAccount.imagePullSecretName=regcred \
  --set controller.nginxplus=true \
  --set controller.nginxStatus.allowCidrs=0.0.0.0/0
```


# Next Steps
Now you can continue to configuring [ArgoCD](argocd.md)
