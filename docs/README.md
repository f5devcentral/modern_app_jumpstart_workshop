# Modern Applications Jumpstart Workshop

This workshop will walk you through common scenarios that an application developer may face as they transition an application from a monolith to microservices.

## Prerequisites

The following resources need to be installed on your laptop:

- [GitHub account](https://github.com)
- [Docker CLI](https://docs.docker.com/engine/install/)
- [Visual Studio Code](https://code.visualstudio.com/)
- [git](https://git-scm.com/downloads)
- [GNU Make](https://www.gnu.org/software/make/) installation:
  - OSX: [installation instructions using XCode or Brew](https://stackoverflow.com/questions/10265742/how-to-install-make-and-gcc-on-a-mac)
  - Windows: [Install WSL](https://learn.microsoft.com/en-us/windows/wsl/install), then install make depending on your installed version of Linux. For example, [install Make on Ubuntu](https://linuxhint.com/install-make-ubuntu/).
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [jq](https://stedolan.github.io/jq/)
- [Hey](https://github.com/rakyll/hey) - HTTP Load testing utility. A drop-in replacement for ApacheBench.
- [GitHub CLI - optional](https://cli.github.com/)
- [cURL](https://curl.se/) - Usually pre-installed in Unix-based Operating systems, available when using Windows with WSL installed.
- NGINX Plus trial license - You will also need to request via SalesForce to obtain an NGINX Plus certificate, private key and JWT.
- Access to F5 Distributed Cloud

You will also need to [setup local authentication](https://docs.github.com/en/authentication) to GitHub.

**Note:** If you are taking this lab on a Windows system, it is **highly** recommended that you [Install Linux on Windows with WSL](https://docs.microsoft.com/en-us/windows/wsl/install).

## Lab 1: Monolith to Microservices Scenario

At the beginning of the workshop we will walk through a common scenario that a developer might take as they transition their application from a monolith to microservices.

[Start Monolith to Microservices Scenario Lab](scenario/README.md)

## Lab 2: K8s Ingress

In this lab, you will build and install the NGINX Plus Ingress Controller into your K3s cluster.  You will also take a deeper look at the VirtualServer Resource and some of the common configurations a modern application might need.

[Start K8s Ingress Lab](ingress/README.md)

## Lab 3: F5 Distributed Cloud Kubernetes Site

In this lab, you will create an F5 Distributed Cloud Kubernetes Site using our existing K3s cluster.  You will then publish the Brewz API service on the Internet without the need for a K8s ingress service.

[Start F5 Distributed Cloud Kubernetes Site Lab](f5xc_k8s_site/README.md)

## Lab 4: Microservices API Security

In this lab, you will gain a basic understanding of modern app security specs, and how to leverage them in order to secure the Brewz microservices-based application in a K8s context.

[Start Microservices API Security Lab](api-security/README.md)
