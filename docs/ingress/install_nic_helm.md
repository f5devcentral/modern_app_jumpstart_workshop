# Install NGINX Plus Ingress Controller via Helm

For this step, we will pull the NGINX Plus Ingress Controller image from your private registry and deploy it into your K3s deployment.

**Note:** For more details, you can access the NGINX Ingress Controller documentation [here](https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-helm/)

## Create a Read-Only GitHub PAT (Personal Access Token)

While you could leverage the PAT created in the build steps, the best practice is to leverage a least privilege model and create a read-only PAT for your Kubernetes cluster.

1. Create a [GitHub PAT (Personal Access Token)](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) with the following scopes:
    - *read:packages*
1. Export the value to the *GITHUB_TOKEN* environment variable.

    ```bash
    export GITHUB_TOKEN=your_access_token
    ```

## Deploy NGINX Ingress Controller Container

Run the following commands to deploy the NGINX Plus Ingress Controller:

```bash
#{% raw %}
# Create nginx-ingress namespace
kubectl create namespace nginx-ingress

# create container registry secret
kubectl create secret docker-registry ghcr -n nginx-ingress --docker-server=ghcr.io --docker-username=${GITHUB_USER} --docker-password=${GITHUB_TOKEN}

# add nginx helm repo
helm repo add nginx-stable https://helm.nginx.com/stable

# Find your nginx tag version
TAG=`docker images ghcr.io/$GITHUB_USER/nginx-plus-ingress --format "{{.Tag}}"`
echo $TAG

# Install NGINX Plus Ingress Controller
helm install nginx-plus-ingress -n nginx-ingress nginx-stable/nginx-ingress \
  --set controller.image.repository=ghcr.io/$GITHUB_USER/nginx-plus-ingress \
  --set controller.image.tag=$TAG \
  --set controller.serviceAccount.imagePullSecretName=ghcr \
  --set controller.nginxplus=true \
  --set controller.enableSnippets=true \
  --set controller.appprotect.enable=true \
  --set controller.appprotectdos.enable=true \
  --set controller.nginxStatus.port=9000 \
  --set controller.nginxStatus.allowCidrs=0.0.0.0/0 \
  --set prometheus.create=true
#{% endraw %}
```
