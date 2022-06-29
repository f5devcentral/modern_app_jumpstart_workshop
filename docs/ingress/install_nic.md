# Install NGINX Plus Ingress
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
# Create nginx-ingress namespace
kubectl create namespace nginx-ingress

# create container registry secret
kubectl create secret docker-registry ghcr -n nginx-ingress --docker-server=ghcr.io --docker-username=${GITHUB_USER} --docker-password=${GITHUB_TOKEN}

# add nginx helm repo
helm repo add nginx-stable https://helm.nginx.com/stable

# Find your nginx tag version
TAG=`docker images ghcr.io/$GITHUB_USER/nginx-plus-ingress --format "{{.Tag}}"`

# install NGINX Plus Ingress Controller
helm install nginx-plus-ingress -n nginx-ingress nginx-stable/nginx-ingress \
  --set controller.image.repository=ghcr.io/$GITHUB_USER/nginx-plus-ingress \
  --set controller.image.tag=$TAG \
  --set controller.serviceAccount.imagePullSecretName=ghcr \
  --set controller.nginxplus=true \
  --set controller.appprotect.enable=true \
  --set controller.appprotectdos.enable=true \
  --set controller.nginxStatus.port=9000 \
  --set controller.nginxStatus.allowCidrs=0.0.0.0/0
```

The helm output should state:`The NGINX Ingress Controller has been installed.`

# Verify Install
Now that NGINX Plus Ingress Controller has been installed, we need to check that our pods are up and running.

## Verify Deployment

To check our pod run the following command:
```shell
kubectl get pods -n nginx-ingress
```
The output should look similar to:
```shell
NAME                                                READY   STATUS    RESTARTS   AGE
nginx-plus-ingress-nginx-ingress-7547565fbc-f8nqj   1/1     Running   0          55m
```

To check our service run the following command:
```shell
kubectl get svcs -n nginx-ingress
```
The output should look similar to:
```shell
NAME                               TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
nginx-plus-ingress-nginx-ingress   LoadBalancer   10.43.129.144   10.1.1.5      80:31901/TCP,443:31793/TCP   57m
```

## Insect Pod Details
Now that we know our NGINX Ingress Controller Pod is up and running, lets dig into some of the pod details.

```shell
NIC_POD=`kubectl get pods -n nginx-ingress -o json | jq '.items[0].metadata.name' -r`
kubectl describe pod $NIC_POC -n nginx-ingress
```

The output should look similar to:
```bash
Name:         nginx-plus-ingress-nginx-ingress-7547565fbc-f8nqj
Namespace:    nginx-ingress
Priority:     0
Node:         ubuntu/10.1.1.5
Start Time:   Tue, 28 Jun 2022 19:11:52 -0500
Labels:       app=nginx-plus-ingress-nginx-ingress
              pod-template-hash=7547565fbc
Annotations:  prometheus.io/port: 9113
              prometheus.io/scheme: http
              prometheus.io/scrape: true
Status:       Running
IP:           10.42.0.7
IPs:
  IP:           10.42.0.7
Controlled By:  ReplicaSet/nginx-plus-ingress-nginx-ingress-7547565fbc
Containers:
  nginx-plus-ingress-nginx-ingress:
    Container ID:  containerd://effa0ec43ba7cba5ea5c1e9cfc0f0fa2397e4dacc5b6a602200597b5520ecd19
    Image:         ghcr.io/codygreen/nginx-plus-ingress:2.2.2-SNAPSHOT-a88b7fe
    Image ID:      ghcr.io/codygreen/nginx-plus-ingress@sha256:af2db8b7fa32a2b021ea6e2a453bca4c05f6a1897dd1c3c82fbee42d9a49c0b8
    Ports:         80/TCP, 443/TCP, 9113/TCP, 8081/TCP
    Host Ports:    0/TCP, 0/TCP, 0/TCP, 0/TCP
    Args:
      -nginx-plus=true
      -nginx-reload-timeout=60000
      -enable-app-protect=false
      -enable-app-protect-dos=false
      -nginx-configmaps=$(POD_NAMESPACE)/nginx-plus-ingress-nginx-ingress
      -default-server-tls-secret=$(POD_NAMESPACE)/nginx-plus-ingress-nginx-ingress-default-server-tls
      -ingress-class=nginx
      -health-status=false
      -health-status-uri=/nginx-health
      -nginx-debug=false
      -v=1
      -nginx-status=true
      -nginx-status-port=8080
      -nginx-status-allow-cidrs=0.0.0.0/0
      -report-ingress-status
      -external-service=nginx-plus-ingress-nginx-ingress
      -enable-leader-election=true
      -leader-election-lock-name=nginx-plus-ingress-nginx-ingress-leader-election
      -enable-prometheus-metrics=true
      -prometheus-metrics-listen-port=9113
      -prometheus-tls-secret=
      -enable-custom-resources=true
      -enable-snippets=false
      -enable-tls-passthrough=false
      -enable-preview-policies=false
      -ready-status=true
      -ready-status-port=8081
      -enable-latency-metrics=false
    State:          Running
      Started:      Tue, 28 Jun 2022 19:12:05 -0500
    Ready:          True
    Restart Count:  0
    Readiness:      http-get http://:readiness-port/nginx-ready delay=0s timeout=1s period=1s #success=1 #failure=3
    Environment:
      POD_NAMESPACE:  nginx-ingress (v1:metadata.namespace)
      POD_NAME:       nginx-plus-ingress-nginx-ingress-7547565fbc-f8nqj (v1:metadata.name)
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-5vpws (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  kube-api-access-5vpws:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:                      <none>
```

Some items of interest from the output:
- Ports:
    - 80/443: http/https traffic
    - 8081: readiness 
    - 9113: Prometheus

# Next Steps
Now you can continue to configuring [ArgoCD](argocd.md)