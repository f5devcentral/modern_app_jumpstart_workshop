# Adding API Protection with NGINX App Protect WAF

The SecOps engineers monitoring the Brewz application have discovered that there appear to be nefarious users and/or bots that have been attempting to perform injection attacks against the API. Additionally, these actors have been spotted trying to exploit destructive HTTP verbs against the API, searching for ways to mine data out of their APIs as well as alter/destroy data.

NGINX Ingress Controller has the ability to configure the NGINX App Protect WAF which will be used to defend against these kind of attacks. The standard "out of the box" capability of NAP WAF will protect against commonly observed injection attacks. However, how can we configure it with knowledge of our Brewz APIs in order to exclude illegitimate API traffic? NAP WAF can build a complex "positive security" policy using an [OpenAPI spec](https://spec.openapis.org/oas/latest.html), which the Brews developers have already produced to describe their APIs. It is just a matter of presenting The OpenAPI spec and NAP policy to NGINX Ingress Controller expressed as custom resources, and it will start enforcing.

## Abuse the API

1. In your local shell, set the `BREWZ_URL` variable with the Brewz UDF Access method in the k3s component (without the trailing slash, and no path parameters). Example:

    ```bash
    BREWZ_URL=https://0d13e993-07ee-4433-91b4-a91788f78847.access.udf.f5.com
    ```

1. Use cURL to make requests against the API. This first request violates the implicitly expected type of `userId` in the user API by injecting alphanumeric characters into it:

    ```bash
    curl -X GET "$BREWZ_URL/api/users/12345b/cart"
    ```

    You should receive a response of `"Could not find user!"`, as `12345b` in not a valid user id format.


1. The next request will attempt a `POST` without the expected payload, and with an invalid and unexpected format of the `userId` parameter:

    ```bash
    curl -X POST "$BREWZ_URL/api/users/12345b/cart"
    ```

    The request should not return anything and just time out. Why?

1. Open a new terminal. Tail the logs in the API pod to see what is going on. You will likely need to set the `KUBECONFIG` variable in this new terminal, so we include this command here:

    ```bash
    export KUBECONFIG=~/Downloads/config-udf.yaml
    API_POD=`kubectl get pods -o json | jq '.items[] | select(.metadata.name | startswith("api-")) | .metadata.name' -r`
    kubectl logs $API_POD -f
    ```
    You may notice that there is an unhandled exception being logged, causing the request to timeout. This is obviously something that should be addressed in code, but we may be able to do something about it in the mean time.


## Create and Deploy Security Policy

We will deploy the NAP WAF policy that is referencing the OpenAPI spec that the Brewz developers provided us. This should stop unexpected and invalid requests from making it through NGINX Ingress Controller, performing as an API Gateway.

1. Copy `waf-ap-logconf.yml`, `waf-ap-policy.yml` and `waf-policy.yml` from your `docs/ingress/source-manifests` folder into your `manifests/brewz` folder.

1. Update your `manifests/brewz/virtual-server.yml` file to add the `waf-policy` policy reference to the `VirtualServer` spec as in this snippet:

    ```yaml
    apiVersion: k8s.nginx.org/v1
    kind: VirtualServer
    metadata:
      name: brewz
    spec:
      host: brewz.f5demo.com
      policies:
        - name: waf-policy
      upstreams:
        - name: spa
          service: spa
          port: 80
    ```

1. Commit the copied and modified files to your local repository, then push them to your remote repository. Argo CD will pick up the most recent changes, and deploy them for you.

1. While it is deploying, review the files you copied:

    - `waf-ap-policy.yml` is the NAP policy itself, packaged into an `APPolicy` custom resource type. It is set to global blocking, and enables blocking for specific violations that we would like to have enforced for the Brewz APIs. Note that the OpenAPI file itself is referenced at the bottom of the policy file. Once the policy is loaded into the ingress controller and presented to NAP, it will be downloaded from the referenced [public GitHub URL](https://raw.githubusercontent.com/f5devcentral/modern_app_jumpstart_workshop/main/docs/ingress/source-manifests/oas.yml). You are free to examine this file now, or later in the exercise. 
    - `waf-ap-logconf.yml` is the logging configuration that NAP WAF will use, packaged as an `APLogConf` custom resource. Note that it is set to log `blocked` requests only.
    - `waf-policy.yml` is a `Policy` custom resource that stitches together the `APPolicy` and `APLogConf` resources. This is the resource that we referenced and attached to the `VirtualServer` resource above.


## Monitor NAP WAF Security Events

If you examine the contents of the `APLogConf` resource contained in `manifests/brewz/waf-ap-logconf.yml` file, you will notice that we have configured NAP WAF to log to `stderr` rather than to a file destination. NGINX Ingress Controller is already logging both access log entries and configuration events to the `stdout` and `stderr` log stream and are viewable with `kubectl logs` executed on its pod. NAP WAF violation logs will now appear in this log stream as well.

Open a new terminal and tail ("follow" with the `-f` option) the NIC pod logs and stream them to your terminal. You will likely need to set the `KUBECONFIG` variable in this new terminal, so we include this command here:

```bash
export KUBECONFIG=~/Downloads/config-udf.yaml
NIC_POD=`kubectl get pods -n nginx-ingress -o json | jq '.items[0].metadata.name' -r`
kubectl logs $NIC_POD -n nginx-ingress -f
```

We will use this log stream in the next section.

**Note:** At times, the log stream may stop. If you are not seeing events appear after some time, type `ctrl+c` and attempt to stream logs again.


## Test for Efficacy

1. We are going to attempt the requests we attempted before:

    ```bash
    curl -X GET "$BREWZ_URL/api/users/12345b/cart"

    curl -X POST "$BREWZ_URL/api/users/12345b/cart"

    ```

    Both of these requests should return a response similar to:

    ```json
    {"supportID": "387465341565226259"}
    ```

1. Examine the log stream. Notice there are NAP WAF log entries that contain violations of `VIOL_URL_CONTENT_TYPE` and `VIOL_PARAMETER_DATA_TYPE` in the logs. This is because NAP WAF is now enforcing expectations associated with requests as dictated by the OpenAPI spec we provided NAP WAF.

1. Attempt a new request that uses a properly formatted `userId`, but does not include the correct content type:

    ```bash
    curl -X POST "$BREWZ_URL/api/users/12345/cart"
    ```

    In the log stream, notice a violation of `VIOL_URL_CONTENT_TYPE` appears. This is due to the fact that line 117 in the `oas.yml` spec file stipulates that requests to this http URI and verb must be of content type `application/json`.

1. Attempt a new request that includes the expected content type, yet violates the request payload expectations:

    ```bash
    curl -d '{"productId":"1234r"}' -H "Content-Type: application/json" -X POST $BREWZ_URL/api/users/12345/cart
    ```

    In the log stream, notice a violation of `VIOL_JSON_SCHEMA` appears. This is due to the fact that line 120 in the `oas.yml` spec file stipulates that requests must include a `productId` property, that is a string that is coercable into a number with a minimum of 3 digits.

1. Finally, send a valid request and note that it is successful and returns all the products in the user cart:

    ```bash
    curl -d '{"productId":"123"}' -H "Content-Type: application/json" -X POST $BREWZ_URL/api/users/12345/cart
    ```

## End of Lab
