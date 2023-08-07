# VirtualServer and VirtualServerRoute Resources

VirtualServer and VirtualServerRoute resources were added into NGINX Ingress Controller starting in version 1.5 and are implemented via [Custom Resources (CRDs)](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/).

The resources enable use cases not supported with the Ingress resource, such as traffic splitting and advanced content-based routing.

More detailed information can be found in the [VirtualServer and VirtualServerRoute Resources docs](https://docs.nginx.com/nginx-ingress-controller/configuration/virtualserver-and-virtualserverroute-resources).

Let's take a look at common resources for a modern application.

> **Note:** You will use your forked version of the **primary** repository for this portion of the lab.

## Action

The action resource defines an action to perform for a request and is the basis for our Brewz demo application.

### Pass

The *pass* action passes the request to an upstream that is defined in the resource.

In the Brewz `virtual-server.yaml` manifest, the *spa* and *api* services leverage this method.

```yaml
...
  upstreams:
    - name: spa
      service: spa
      port: 8080
    - name: api
      service: api
      port: 8000
...
  routes:
    - path: /
      action:
        pass: spa
    - path: /api
      action:
        pass: api
...
```

### Redirect

The *redirect* action redirects a request to a provided URL.

### Return

The *return* action returns a preconfigured response.

### Proxy

The *proxy* action passes a request to an upstream with the ability to modify the request/response.

In the Brewz `virtual-server.yaml` manifest, the */images* path uses this method to proxy requests to the api service's */images* path.

```yaml
...
    - path: /images
      action:
        proxy:
          upstream: api
          rewritePath: /images
...
```

## Upstreams

The upstream defines a destination for the routing configuration. The upstream's name must be a valid DNS label as defined in RFC 1035.

In the Brewz `virtual-server.yaml` manifest, we define a very simple upstream configuration for the *spa* and *api* services:

```yaml
...
  upstreams:
    - name: spa
      service: spa
      port: 8080
    - name: api
      service: api
      port: 8000
...
```

While this configuration meets our requirements for a lab, in a production environment you may need more advanced configurations.  For example, if we knew that the API server could only handle 32 concurrent connections then we may want to modify the manifest to include the *max-conns* attribute:

```yaml
...
  upstreams:
    - name: spa
      service: spa
      port: 8080
    - name: api
      service: api
      port: 8000
      max-conns: 32
...
```

For a full list of Upstream attributes, please refer to the [docs](https://docs.nginx.com/nginx-ingress-controller/configuration/virtualserver-and-virtualserverroute-resources/#upstream).

### HealthCheck

One of the advantages the NGINX Plus Ingress Controller provides is the ability to perform health checks on your upstreams. This can be very useful in situations like the Brewz API which is dependent on a MongoDB database to function correctly.  By checking the APIs' custom /stats API, we can determine if the API server is functioning correctly.

1. In VSCode, open the `manifests/brewz/virtual-server.yaml` file and add a `healthCheck` resource to the `api` upstream; example below.

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
          healthCheck:
            enable: true
            path: /api/stats
            interval: 20s
            jitter: 3s
            port: 8000
        - name: inventory
          service: inventory
          port: 8002
        - name: recommendations
          service: recommendations
          port: 8001
        - name: spa-dark
          service: spa-dark
          port: 8080
      routes:
        - path: /
          matches:
            - conditions:
              - cookie: "app_version"
                value: "dark"
              action:
                pass: spa-dark
          action:
            pass: spa
        - path: /api
          policies:
            - name: rate-limit-policy
          action:
            pass: api
        - path: /api/inventory
          action:
            proxy:
              upstream: inventory
              rewritePath: /api/inventory
        - path: /api/recommendations
          action:
            proxy:
              upstream: recommendations
              rewritePath: /api/recommendations
        - path: /images
          action:
            proxy:
              upstream: api
              rewritePath: /images
    ```

1. Commit the `manifests/brewz/virtual-server.yaml` file to your local repository, then push it to your remote repository. ArgoCD will pick up the most recent changes, and deploy them for you.

    > **Note:** ArgoCD does not *immediately* detect changes. By default, it checks the repository for changes every 3 minutes. You can click the **Refresh** button on the **brewz** application in ArgoCD to immediately check for updated repository contents. If any are detected, ArgoCD will initiate a sync.

1. Run the following command on your laptop to test that our API services is still up and has a health check:

    ```bash
    BREWZ_URL=<Your Brewz UDF access method url>
    curl -k https://$BREWZ_URL/api/products/123
    ```

## ErrorPage

While the Brewz developers were able to break their monolith application into microservices, their APIs are not always returning a JSON response. A good example is when you lookup a product that does not exist. The API returns a 400 HTTP response code but the body payload is *"Could not find the product!"*.

1. Run the following command on your laptop to test this output:

    ```bash
    curl -k https://$BREWZ_URL/api/products/1234
    ```

    Ideally, the development team will fix this issue in the API code but we can also help by performing a quick fix via our VirtualServer configuration.

    > **Note:** Since the error response override we will be adding in the next steps could apply to multiple `404` entities on the api (users, products, cart, etc), we will generically use the term "resource" when creating the error response override.

1. In VSCode, open the `manifests/brewz/virtual-server.yaml` file and add an `errorPages` resource to the `routes` -> `/api` path; example below.

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
          healthCheck:
            enable: true
            path: /api/stats
            interval: 20s
            jitter: 3s
            port: 8000
        - name: inventory
          service: inventory
          port: 8002
        - name: recommendations
          service: recommendations
          port: 8001
        - name: spa-dark
          service: spa-dark
          port: 8080
      routes:
        - path: /
          matches:
            - conditions:
              - cookie: "app_version"
                value: "dark"
              action:
                pass: spa-dark
          action:
            pass: spa
        - path: /api
          policies:
            - name: rate-limit-policy
          action:
            pass: api
          errorPages:
            - codes: [404]
              return:
                code: 404
                type: application/json
                body: |
                  {\"msg\": \"Could not find the resource!\"}
                headers:
                  - name: x-debug-original-status
                    value: ${upstream_status}
        - path: /api/inventory
          action:
            proxy:
              upstream: inventory
              rewritePath: /api/inventory
        - path: /api/recommendations
          action:
            proxy:
              upstream: recommendations
              rewritePath: /api/recommendations
        - path: /images
          action:
            proxy:
              upstream: api
              rewritePath: /images
    ```

1. Commit the `manifests/brewz/virtual-server.yaml` file to your local repository, then push it to your remote repository. ArgoCD will pick up the most recent changes, and deploy them for you.

1. Now, check that an unknown product returns a JSON object by running the following command on your laptop:

    ```bash
    curl -k https://$BREWZ_URL/api/products/1234
    ```

    > Your output should look like: `{"msg": "Could not find the resource!"}`

## TLS

A common requirement for most websites today is to leverage encryption to secure the communication between the client and the server. While this would be a critical requirement for an e-commerce site like our Brewz demo app, many enterprise customers also require encryption due to search engines, such as Google, demoting their rank in search results if the website does not offer encryption.

In this step, we will add TLS encryption to the Brewz VirtualServer resource.

### Create a certificate

Since you are running this lab in a closed ecosystem (UDF), you do not have the ability to easily create external DNS records and obtain a public TLS certificate; we will look at this ability in another lab leveraging F5 Distributed Cloud. Due to this limitation, we will create a self-signed certificate.

1. Run the following commands via SSH on the K3s server using the *SSH* or *Web Shell* UDF Access Methods:

    ```bash
    # Create the key and cert
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/brewz-selfsigned.key -out /etc/ssl/certs/brewz-selfsigned.crt
    ```

    OpenSSL will prompt you with questions about your cert request:

    - Country Name: US
    - State or Province Name: WA
    - Locality Name: Seattle
    - Organization Name: F5
    - Organizational Unit Name: Brewz
    - Common Name: brewz.f5demo.com
    - Email Address: brewz@f5demo.com

### Create K8s Secret for the Cert and Key

Now that we have a self-signed certificate, we need to add it to our K8s cluster as a secret.

1. Run the following commands via SSH on the K3s server using the *SSH* or *Web Shell* UDF Access Methods:

    ```bash
    sudo kubectl create secret tls brewz-tls --key=/etc/ssl/private/brewz-selfsigned.key --cert=/etc/ssl/certs/brewz-selfsigned.crt
    ```

1. Now that your secret is created, let's take a look at it. Run the following command from your laptop:

    ```bash
    kubectl describe secret brewz-tls
    ```

    Your output should look similar to:

    ```shell
    Name:         brewz-tls
    Namespace:    default
    Labels:       <none>
    Annotations:  <none>

    Type:  kubernetes.io/tls

    Data
    ====
    tls.crt:  1164 bytes
    tls.key:  1704 bytes
    ```

### Modify VirtualServer Resource

The final step is to update our Brewz VirtualServer resource to leverage the new TLS certificate.

1. In VSCode, open the `manifests/brewz/virtual-server.yaml` file and add the following fields to the virtual server:

    ```yaml
      tls:
        secret: brewz-tls
    ```

    The final file should look like the example below:

    ```yaml
    ---
    apiVersion: k8s.nginx.org/v1
    kind: VirtualServer
    metadata:
      name: brewz
    spec:
      host: brewz.f5demo.com
      tls:
        secret: brewz-tls
      upstreams:
        - name: spa
          service: spa
          port: 8080
        - name: api
          service: api
          port: 8000
          healthCheck:
            enable: true
            path: /api/stats
            interval: 20s
            jitter: 3s
            port: 8000
        - name: inventory
          service: inventory
          port: 8002
        - name: recommendations
          service: recommendations
          port: 8001
        - name: spa-dark
          service: spa-dark
          port: 8080
      routes:
        - path: /
          matches:
            - conditions:
              - cookie: "app_version"
                value: "dark"
              action:
                pass: spa-dark
          action:
            pass: spa
        - path: /api
          policies:
            - name: rate-limit-policy
          action:
            pass: api
          errorPages:
            - codes: [404]
              return:
                code: 404
                type: application/json
                body: |
                  {\"msg\": \"Could not find the resource!\"}
                headers:
                  - name: x-debug-original-status
                    value: ${upstream_status}
        - path: /api/inventory
          action:
            proxy:
              upstream: inventory
              rewritePath: /api/inventory
        - path: /api/recommendations
          action:
            proxy:
              upstream: recommendations
              rewritePath: /api/recommendations
        - path: /images
          action:
            proxy:
              upstream: api
              rewritePath: /images
    ```

1. Commit the `manifests/brewz/virtual-server.yaml` file to your local repository, then push it to your remote repository. ArgoCD will pick up the most recent changes, and deploy them for you.

### Check the status of our virtual server

1. Check the state of the Virtual Server, it should be *Valid*:

    ```bash
    kubectl get vs
    ```

1. Open a **WebShell** for the K3s server in the UDF deployment

1. Check the SSL certificate on the NGINX Ingress, notice the CN is NGINXIngressController

    ```bash
    echo | openssl s_client -connect 10.1.1.5:443 2> /dev/null | grep subject=
    ```

1. Now, check the SSL certificate for the **brewz.f5demo.com** Virtual Server, notice the certificate information you entered when you created the cert:

    ```bash
    echo | openssl s_client -connect 10.1.1.5:443  -servername brewz.f5demo.com 2> /dev/null | grep subject=
    ```

## Next Steps

Next, you will [look at the Canary deployment pattern](canary.md).
