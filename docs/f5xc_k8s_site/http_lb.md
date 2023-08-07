# F5 Distributed Cloud Kubernetes Site - Virtual Server

In this step, we will leverage the F5 Distributed cloud to publish the Brewz API directly from our Kubernetes cluster without the need for an Ingress service.

## Create Origin Pools

In this step, you need to create 4 origin pools:

- api
- inventory
- recommendations
- spa (single page application)

Follow the [F5 Distributed Cloud Origin Pool docs](https://docs.cloud.f5.com/docs/how-to/app-networking/origin-pools) instructions.

> Note: you must select your namespace versus using the default namespace

Use the following settings:

- Select Type of Origin Server: k8s Service Name of Origin Server on given Sites
- Service:
  - api:
    - Service Name: api.default
    - Port: 8000
  - inventory:
    - Service Name: inventory.default
    - Port: 8002
  - recommendations:
    - Service Name: recommendations.default
    - Port: 8001
  - spa:
    - Service Name: spa.default
    - Port: 8080
- Site: the site you created in the previous step
- Select Network on the site: Outside Interface

## Configure the Virtual Server

Follow the [F5 Distributed Cloud HTTP Load Balancer docs](https://docs.cloud.f5.com/docs/how-to/app-networking/http-load-balancer) to create an **HTTP Load Balancer** for the Brewz API service.

Use the following settings:

- List of Domains: brewz-username.lab-app.f5demos.com
- Choose `HTTP` from the Load Balancer Type dropdown menu
- Automatically Manage DNS Records: Check
- Origin Pool: the SPA origin pool

### Routes

In this step, you will configure the HTTP routes to direct requests to the appropriate microservice.

Please review the [How to Setup path-based routing](https://f5cloud.zendesk.com/hc/en-us/articles/4405130078103-How-to-setup-path-based-routing-or-application-load-balancing) for detailed instructions on how to configure routes for an HTTP load balancer.

You will need to build a route for the Brewz microservices: API, inventory, and recommendations.

The following settings should be modified from their default:

- HTTP Method: ANY

**Note:** The order of the defined routes matters since we're using the prefix path match setting. The API route needs to be the last in the order.

Prefixes:

- /api/inventory - choose the `inventory` origin pool
- /api/recommendations - choose the `recommendations` origin pool
- /api - choose the `api` origin pool

Now we also need a route to direct /images requests to the API service.

Follow the same steps as above, but change the *HTTP Method* to *GET* and the *Origin Pools* to your `api` origin pool.

Once you create the */images* path, drag it above the */api* path to change its order; we want */api* to be the last path processed.

## Testing

At this point, you should have an HTTP LB that you can access the Brewz app at:

`<http://brewz-username.lab-app.f5demos.com/>`

## Cleanup

Now that you have completed the lab, please delete the resources you created:

- HTTP Load Balancer
- Origin Pools
- [K8s site](https://docs.cloud.f5.com/docs/how-to/site-management/create-k8s-site#decommission-a-site)

## End of Lab

F5 Distributed Cloud Kubernetes Site lab complete. Return to [workshop index](../README.md).
