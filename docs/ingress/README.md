# Lab 2: K8s Ingress

In this lab you will build and deploy the NGINX Plus-based Ingress Controller.

> **Important:** You must have completed [Lab 1](../scenario/README.md) before you can start this lab.

## Requirements

For this lab, you will need:

- [GitHub account](https://github.com)
- [Docker CLI](https://docs.docker.com/engine/install/)
- [Visual Studio Code](https://code.visualstudio.com/)
- [git](https://git-scm.com/downloads)
- [GNU Make](https://www.gnu.org/software/make/) installation:
  - OSX: [installation instructions using XCode or Brew](https://stackoverflow.com/questions/10265742/how-to-install-make-and-gcc-on-a-mac)
  - Windows: [Install WSL](https://learn.microsoft.com/en-us/windows/wsl/install), then install make depending on your installed version of Linux. For example, [install Make on Ubuntu](https://linuxhint.com/install-make-ubuntu/).
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Hey](https://github.com/rakyll/hey)
- [GitHub CLI - optional](https://cli.github.com/)

> **Note:** You will also need to request an NGINX Plus trial via SalesForce to obtain an NGINX Plus certificate and private key. If you are presented with the option to download a JWT file, please also download it so that it can be used in an alternative part of this lab.

## Resources

- [NGINX Ingress Controller documentation](https://docs.nginx.com/nginx-ingress-controller/)

## Steps

- [Setup](setup.md)
- [Install ArgoCD](argocd.md)
- [Build NGINX Plus Ingress Controller container](build_nic.md)
- [Install NGINX Plus Ingress Controller](install_nic.md)
- [Install Prometheus](install_prometheus.md)
- [Install Grafana](install_grafana.md)
- [Install the Brewz Application](brewz.md)
- [NGINX Ingress Controller Virtual Server](virtualserver.md)
- [Canary deployment pattern](canary.md)
- [API protection with NGINX App Protect WAF](waf.md)
