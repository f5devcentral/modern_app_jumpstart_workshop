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