# Modern Applications Jumpstart Workshop

This workshop will walk you through common scenarios that an application developer may face as they transition their application from a monolith to microservices.

## Prerequisites

The following resources need to be installed on your laptop:

- [Visual Studio Code](https://code.visualstudio.com/)
- [git](https://git-scm.com/downloads)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [ApacheBench](https://httpd.apache.org/docs/2.4/programs/ab.html)
- [GitHub CLI - optional](https://cli.github.com/)

You will also need to [setup authentication](https://docs.github.com/en/authentication) to GitHub.

## Monolith to Microservices Scenario

At the beginning of the workshop we will walk through a common scenario that a developer might take as they transition their application from a monolith to microservices.

[Start Scenario](scenario/README.md)

## K8s Ingress

In this lab, you will build and install the NGINX Plus Ingress Controller into your K3s cluster.  You will also take a deeper look at the VirtualServer Resource and some of the common configurations a modern application might need.

[Start Ingress Lab](ingress/README.md)
