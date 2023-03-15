# Use NGINX Ingress Controller to inspect and enforce JWT

Though we just discovered that the Brewz API JWT is not being enforced, the good news is that we don't have to rely on developer code to inspect and enforce this JWT for us. As mentioned in the outset of this lab, security development is hard to get right. Why would we want to implement our own security measures on our microservices? Additionally, many organizations have multiple APIs that have security requirements. Why would we want to implement duplicate code across all of our services?

We are already using NGINX Ingress Controller as an API Gateway - the ideal location to provide security enforcement. It is already decrypting our request traffic to make routing decisions, rate-limit traffic as well as using its WAF to prevent the exploitation of vulnerabilities. It makes sense to implement this additional security control at this tier, instead of adding an additional tier to do so. NGINX Ingress Controller based on NGINX Plus already has JWT introspection and enforcement capabilities, and we can enable these via a `Policy` resource on our existing `VirtualServer` resource. Let's get started.

## JSON Web Key Sets for JWT signing

Public keys are used to verify the cryptographic authenticity of the JWT token to ensure that their contents are from the expected issuer (Azure), and that their contents have not been tampered with since it was issued. Like the JWT, the structure of the keys are also expressed as JSON structure, called a [JSON Web Key Set (JWKS)](https://datatracker.ietf.org/doc/html/rfc7517#section-5).

You can configure NGINX Ingress Controller to reference a Kubernetes `Secret` containing the JWKS, but we will instead configure it to download and cache a JWKS from a remote location.

Where do we get the JWKS URL? It will vary per authentication provider. Azure makes them publicly available for download based on your tenant ID, but not well documented. [This](https://www.nginx.com/blog/secure-api-access-with-nginx-and-azure-active-directory/#Configure-JWT-Assertion-in-API-Connectivity-Manager) seems to be the best resource I have seen on the topic. However, we will provide you the JWKS URI to use in this lab.

## Create a JWT Policy and apply it to the VirtualServer

We will create a `Policy` resource in Kubernetes to inspect and enforce the JWT authorization. The Policy will reference the Secret containing the JWKS we've already created. We can then apply this policy to the `/api/order` route context in our existing `VirtualServer`.

1. In VS Code, create a `manifests/brewz/jwt.yaml` file in your repository with the following contents:

    ```yaml
    apiVersion: k8s.nginx.org/v1
    kind: Policy
    metadata:
      name: jwt-policy
    spec:
      jwt:
        realm: BrewzAPI
        jwksURI: "https://login.microsoftonline.com/e569f29e-b098-4cea-b6f0-48fa8532d64a/discovery/v2.0/keys"
        keyCache: 1h
    ```

1. Save the file, and stage the changes.

1. Open the `manifests/brewz/virtual-server.yaml` file, and add the following `policies` field to the `routes` -> `/api/order` path so it looks like this:

    ```yaml
        - path: /api/order
          policies:
            - name: jwt-policy
          action:
            proxy:
              upstream: checkout
              rewritePath: /api/order
    ```

1. Save the file, and stage the changes.

1. Commit the changes to your local repository.

1. Push the changes to your remote repository.

1. Argo CD will detect the changes to your repository, and will update the Brewz app deployment.

    > **Note:** In the UDF environment, at times Argo CD may not immediately detect and deploy the changes. If this is the case, click the **Refresh** button on the **brewz** application in Argo CD.

1. Once the application updates have deployed, use the cURL to test the `/api/order` operation as you did on the previous page of this lab. You will receive a `401 Authorization Required` error as now NGINX is expecting a JWT token to be present before forwarding the request to the Checkout service.

    <img src="../assets/term_order_service_401_html.png" alt="401 response in html" width="750"/>

    > **Note:** Notice that this error reponse is HTML, although the `Accept` and `Content-Type` headers are set to `application/json`. Since the Brewz SPA is always expecting JSON responses from its APIs, we need to return JSON payloads even in an error condition, so the SPA will understand how to parse it.

## Set JSON in the 401 response code

As in a previous lab in this workshop, we need to add additional fields to our `VirtualServer` resource manifest to override the default error code responses.

1. In VSCode, open the `manifests/brewz/virtual-server.yaml` file and add an `errorPages` resource to the `routes` -> `/api/order` path; example below.

    ```yaml
        - path: /api/order
          policies:
            - name: jwt-policy
          action:
            proxy:
              upstream: checkout
              rewritePath: /api/order
          errorPages:
            - codes: [401]
              return:
                code: 401
                type: application/json
                body: |
                  {\"msg\": \"Authorization Required\"}
                headers:
                  - name: x-debug-original-status
                    value: ${upstream_status}
    ```

1. Save the file, and stage the changes.

1. Commit the changes to your local repository.

1. Push the changes to your remote repository.

1. Once again, run the cURL command to test the Checkout API. Add a `-v` option to the end of the command to see the actual response code:

    <img src="../assets/term_order_service_401_json.png" alt="401 response in json"/>

1. Note that the response code is `401 Unauthorized`, `content-type: application/json`, and a payload of `{"msg": "Authorization Required"}` which is now well-formed JSON that the SPA application can consume.

## Next Steps

From an API perspective, what can we do with the claim data that is present in the JWT token? We can selectively [pass claim data to the upstream api](claim-data.md).
