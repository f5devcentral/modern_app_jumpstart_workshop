# F5 Distributed Cloud Kubernetes Site - Virtual Server

In this step, we will leverage the F5 Distributed cloud to publish the Brewz API directly from our Kubernetes cluster without the need for an Ingress service.

## Configure Origin Pool

Follow the [F5 Distributed Cloud Origin Pool docs](https://docs.cloud.f5.com/docs/how-to/app-networking/origin-pools) instructions.

Use the following settings:

- Select Type of Origin Server: k8s Service Name of Origin Server on given Sites
- Service Name: api.default
- Site: the site you created in the previous step
- Select Network on the site: Outside
- port number: 8000

## Configure the Virtual Server

Follow the [F5 Distributed Cloud HTTP Load Balancer docs](https://docs.cloud.f5.com/docs/how-to/app-networking/http-load-balancer) to create an HTTP Load Balancer for the Brewz API service.

Use the following settings:

- List of Domains: brewz-username.lab-app.f5demos.com
- Origin Pool: the pool you created in the previous step

At this point, you should have an HTTP LB that you can access the Brewz API at:

`<http://brewz-username.lab-app.f5demos.com/api/products>`
