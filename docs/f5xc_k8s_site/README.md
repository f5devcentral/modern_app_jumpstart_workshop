# Lab 3: F5 Distributed Cloud Kubernetes Site

In this lab, you will evaluate alternative options for publishing services from a K8s cluster leveraging F5 Distributed Cloud.

> **Important:** You must have completed both [Lab 1](../scenario/README.md) and [Lab 2](../ingress/README.md) before you can start this lab.

## Resources

- [F5 XC Create a Kubernetes Site Docs](https://docs.cloud.f5.com/docs/how-to/site-management/create-k8s-site)

## Prerequisites

This lab assumes that you have already completed the [NGINX Ingress lab](../ingress/README.md) and have running instances of the Brewz microservices in your K8s cluster. If not, please complete those steps first.

You must also have access to an F5 Distributed Cloud tenant.  If not, F5 employees can request access through the Cloud Account ServiceNow form and non-employees can [sign-up](https://www.f5.com/cloud/pricing#container1989174610).

## K8s Site Deployment  

1. [Create a site token](https://docs.cloud.f5.com/docs/how-to/site-management/create-k8s-site)
2. [Prepare a manifest file](https://docs.cloud.f5.com/docs/how-to/site-management/create-k8s-site) using the [manifest template](https://gitlab.com/volterra.io/volterra-ce/-/blob/master/k8s/ce_k8s.yml)
3. Update the manifest file with the required attributes:
    - **ClusterName**: *username-k8s-site*
    - **Latitude**: *47.608013*
    - **Longitude**: *-122.335167*
    - **Token**: *token generated in step 1*

**Note:** Your manifest file contains a sensitive token, please do not commit it back into your repository.

## Deploy

Now that you have created your custom manifest file, we will deploy the manifest on the K3s server in your UDF deployment:

```bash
kubectl apply -f f5xc_k8s_site.yaml
```

Verify the deployment by running the following command:

```bash
kubectl get pods -n ves-system -o=wide
```

## Next Steps

The F5 Distributed Cloud documentation is very well written and offers detailed instructions for completing the remaining registry steps.  Please follow the remaining instructions in the [F5 XC Create a Kubernetes Site Docs - Single Node Site Registration](https://docs.cloud.f5.com/docs/how-to/site-management/create-k8s-site#single-node-site-registration) and then come back to the lab guide.

Once your Kubernetes site is up and ready, proceed to configuring your [HTTP Load Balancer](http_lb.md)
