# Modern Applications Jumpstart Workshop

This workshop will walk you through common scenarios that an application developer may face as they transition their application from a monolith to microservices.

## Prerequisites

The following resources need to be installed on your laptop:

- [GitHub account](https://github.com)
- [Docker CLI](https://docs.docker.com/engine/install/)
- [Visual Studio Code](https://code.visualstudio.com/)
- [git](https://git-scm.com/downloads)
- [GNU Make](https://www.gnu.org/software/make/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Hey](https://github.com/rakyll/hey) - HTTP Load testing utility. A drop-in replacement for ApacheBench.
- [GitHub CLI - optional](https://cli.github.com/)
- NGINX Plus trial license - You will also need to request via SalesForce to obtain an NGINX Plus certificate and private key.
- Access to F5 Distributed Cloud

You will also need to [setup local authentication](https://docs.github.com/en/authentication) to GitHub.

**Note:** If you are taking this lab on a Windows system, it is **highly** recommended that you [Install Linux on Windows with WSL](https://docs.microsoft.com/en-us/windows/wsl/install).

## Monolith to Microservices Scenario

At the beginning of the workshop we will walk through a common scenario that a developer might take as they transition their application from a monolith to microservices.

[Start Scenario](scenario/README.md)

## K8s Ingress

In this lab, you will build and install the NGINX Plus Ingress Controller into your K3s cluster.  You will also take a deeper look at the VirtualServer Resource and some of the common configurations a modern application might need.

[Start Ingress Lab](ingress/README.md)

## F5 Distributed Cloud Kubernetes Site

In this lab, you will create an F5 Distributed Cloud Kubernetes Site using our existing K3s cluster.  You will then publish the Brewz API service on the Internet without the need for a K8s ingress service.

[Start F5 XC Kubernetes Site Lab](f5xc_k8s_site/README.md)
