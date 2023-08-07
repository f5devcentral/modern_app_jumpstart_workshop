# Introduce API rate-limiting

Currently, there is no limitation on the rate that clients may query the product catalog. We would like to implement a rate limiting feature on the API to prevent a general degradation of service condition caused by unwanted users of the Brewz site.

1. Test the initial state of the API with the [Hey](https://github.com/rakyll/hey) utility:

    ```bash
    BREWZ_URL=<Your Brewz UDF access method url without the path>
    hey -n 20 -c 10 $BREWZ_URL/api/products
    ```

    > Note that **Hey** should report `Status code distribution: [200] 20 responses` in its results.

    We will create a rate limiting policy for NGINX Ingress Controller, and attach it specifically to the `/api` VirtualServerRoute that has already been defined.

1. Open your forked workshop GitHub repo in VSCode. Ensure you are working on the `main` branch, and it is up to date. Create a `manifests/brewz/rate-limit.yaml` file with the following contents, and save the file:

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

1. Edit the existing `manifests/brewz/virtual-server.yaml` file to add the rate limiting policy to the /api path. The file should now look like this:

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
          port: 8080
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

1. Save this file.

    > **Note:** You can manually test that changes to your YAML manifests are both well-formed and syntactically correct by performing a *dry-run* test with `kubectl apply` without actually applying them. Example:

    ```bash
    kubectl apply -f manifests/brewz/virtual-server.yaml --dry-run=client
    ```

    If successful, the command will return a result similar to:

    ```shell
    virtualserver.k8s.nginx.org/brewz configured (dry run)
    ```

    Keep this technique in mind for the remainder of this workshop if you are uncertain that your YAML manifests have been formatted correctly.

1. Stage the changes to both files, and commit them to your local repository.

1. Push the changes to your remote repository.

1. Return to the ArgoCD UI, and click refresh after 30 seconds or so has elapsed. Note that an automatic synchronization has occurred, and you will now see that the `rate-limit-policy` object has been added to the object graph. You may optionally click on it to view the configuration details associated with it (including its deployment status).

    > **Note:** ArgoCD does not *immediately* detect changes. By default, it checks the repository for changes every 3 minutes. You can click the **Refresh** button on the **brewz** application in ArgoCD to immediately check for updated repository contents. If any are detected, ArgoCD will initiate a sync.

1. Test the new rate limiting settings with **Hey**:

    ```bash
    hey -n 20 -c 10 $BREWZ_URL/api/products
    ```

    > Note that **Hey** should report a result similar to `Status code distribution: [200] 12 responses, [503] 8 responses` (the distribution in your results may vary slightly). Why? When the number of requests per second per unique client IP configured in the rate limit policy had been exceeded, NGINX Ingress Controller started to respond with a `503 Service Unavailable` HTTP response, which signified an error response to Hey.

## Next Steps

Achieve granular scalability and non-disruptive application deployments in [Refactor-to-microservices](refactor.md).
