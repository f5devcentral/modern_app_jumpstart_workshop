# Build NGINX Plus Ingress Controller Container
In this step, you will build a copy of the NGINX Plus Ingress Controller container and push it to your private container registry.

You can also reference the official [NGINX Ingress Controller documentation](https://docs.nginx.com/nginx-ingress-controller/) for additional details.

## Clone the NGINX Ingress Controller Repository
In your terminal, clone the Official [NGINX Ingress Controller repository](https://github.com/nginxinc/kubernetes-ingress.git)

```bash
git clone https://github.com/nginxinc/kubernetes-ingress.git
```

## Build the Container
For this step, we will leverage the Docker CLI to build the NGINX Ingress Controller image. 

The repository's Makefile supports several [target types](https://docs.nginx.com/nginx-ingress-controller/installation/building-ingress-controller-image/#makefile-targets), but for this lab we will leverage the *debian-image-nap-dos-plus* target so we can use NGINX App Protect.

**Note:** For additional details you can also reference the [Build the Ingress Controller Image](https://docs.nginx.com/nginx-ingress-controller/installation/building-ingress-controller-image/) portion of the [NGINX Ingress Controller documentation](https://docs.nginx.com/nginx-ingress-controller/).

Follow the following steps:
1. 