# Introduce API rate-limiting

Currently, there is no limitation on the rate that clients may query the product catalog. We would like to implement a rate limiting feature on the API to prevent a general degradation of service condition caused by unwanted users of the Brewz site.

Test the initial state of the API with the [Hey](https://github.com/rakyll/hey) utility:

```bash
BREWZ_URL=<Your Brewz UDF access method url>
hey -n 20 -c 10 $BREWZ_URL/api/products
```

Note that Hey should report`Status code distribution: [200] 20 responses` in its results.

We will create a rate limiting policy for NGINX Ingress Controller, and attach it specifically to the `/api` VirtualServerRoute that has already been defined.

Open your forked workshop GitHub repo in VSCode. Ensure you are working on the `main` branch, and it is up to date. Create a `manifests/brewz/rate-limit.yml` file with the following contents, and save the file:

```yaml
---
apiVersion: k8s.nginx.org/v1
kind: Policy
metadata:
  name: rate-limit-policy
spec:
  rateLimit:
    rate: 10r/s
    burst: 10
    noDelay: true
    key: ${binary_remote_addr}
    zoneSize: 10M
```

Edit the existing `manifests/brewz/virtual-server.yml` file to add the rate limiting policy to the /api path. The file should now look like this:

```yaml
---
apiVersion: k8s.nginx.org/v1
kind: VirtualServer
metadata:
  name: brewz
spec:
  host: brewz.f5demo.com
  upstreams:
    - name: spa
      service: spa
      port: 80
    - name: api
      service: api
      port: 8000
  routes:
    - path: /
      action:
        pass: spa
    - path: /api
      policies:
        - name: rate-limit-policy
      action:
        pass: api
    - path: /images
      action:
        proxy:
          upstream: api
          rewritePath: /images
```

Save this file. Stage the changes, and commit them to your local repository. Push the changes to your remote repository.

Commit it directly to your main branch. Return to the Argo CD UI, and click refresh after 30 seconds or so has elapsed. Note that an automatic synchronization has occurred, and you will now see that the `rate-limit-policy` object has been added to the object graph. You may optionally click on it to view the configuration details associated with it (including its deployment status).

Test the new rate limiting settings with Hey:

```bash
hey -n 20 -c 10 $BREWZ_URL/api/products
```

Note that Hey should report `Status code distribution: [200] 12 responses, [503] 8 responses`. Why? When the number of requests per second per unique client IP configured in the rate limit policy had been exceeded, NGINX Ingress Controller started to respond with a `503 Service Unavailable` HTTP response, which signified an error response to Hey.

## Next Steps
Achieve granular scalability and non-disruptive application deployments in [Refactor-to-microservices](refactor.md).
