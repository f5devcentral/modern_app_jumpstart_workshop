# Install Brewz with ArgoCD

In this section, you will deploy the Brewz microservices application using ArgoCD.

## Update ArgoCD Application Manifest

You will need to update the Brewz ArgoCD manifest to match your environment.  

1. Open the `manifests/brewz-subchart.yaml` file in your forked version of the **primary** repository.

1. Find the following variables and replace them with your information:

    | Variable        | Value                |
    |-----------------|----------------------|
    | \<GITHUB_USER\> | your github username |

    Your file should look similar to the example below:

    ```yaml
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: brewz
      namespace: argocd
      finalizers:
        - resources-finalizer.argocd.argoproj.io
    spec:
      project: default
      source:
        path: manifests/brewz
        repoURL: https://github.com/codygreen/modern_app_jumpstart_workshop.git
        targetRevision: HEAD
      destination:
        namespace: default
        server: https://kubernetes.default.svc
      syncPolicy:
        automated:
          selfHeal: true
          prune: true
    ```

1. Save the file.

1. Stage the changes, and commit to your local **primary** repository.

1. Push the changes to your remote **primary** repository.

## Deploy the manifest

1. To deploy the Brewz ArgoCD application, run the following command:

    ```bash
    kubectl apply -f manifests/brewz-subchart.yaml
    ```

## View the ArgoCD Application

1. Open the ArgoCD UDF Access Method under the K3s server
  ![ArgoCD Sync](../assets/argo_sync.jpg)

1. Click on the **brewz** application in the ArgoCD UI and inspect the deployed services and policies.

    > **Note:** You should see the individual services as well as the `rate-limit-policy` resource from an earlier lab in this workshop.

## Inspect the NGINX Ingress Controller Configuration

Now that ArgoCD has deployed out application let's take a look at the NGINX Ingress Controller Virtual Server resources.

**Note:** Refer to the [VirtualServer docs](https://docs.nginx.com/nginx-ingress-controller/configuration/virtualserver-and-virtualserverroute-resources/) for more information.

1. Run the following on your local machine:

    ```bash
    kubectl get virtualserver
    ```

    Your output should look similar to:

    ```bash
    NAME    STATE   HOST               IP         PORTS      AGE
    brewz   Valid   brewz.f5demo.com   10.1.1.5   [80,443]   29m
    ```

1. Let's take a deeper look at the configuration:

    ```shell
    kubectl describe virtualserver brewz
    ```

    Your output should look similar to:

    ```shell
    Name:         brewz
    Namespace:    default
    Labels:       app.kubernetes.io/instance=brewz
    Annotations:  <none>
    API Version:  k8s.nginx.org/v1
    Kind:         VirtualServer
    Metadata:
      Creation Timestamp:  2022-07-06T16:51:10Z
      Generation:          1
      Managed Fields:
        API Version:  k8s.nginx.org/v1
        Fields Type:  FieldsV1
        fieldsV1:
          f:metadata:
            f:annotations:
              .:
              f:kubectl.kubernetes.io/last-applied-configuration:
            f:labels:
              .:
              f:app.kubernetes.io/instance:
          f:spec:
            .:
            f:host:
            f:http-snippets:
            f:routes:
            f:server-snippets:
            f:upstreams:
        Manager:      argocd-application-controller
        Operation:    Update
        Time:         2022-07-06T16:51:10Z
        API Version:  k8s.nginx.org/v1
        Fields Type:  FieldsV1
        fieldsV1:
          f:status:
            .:
            f:externalEndpoints:
            f:message:
            f:reason:
            f:state:
        Manager:         Go-http-client
        Operation:       Update
        Subresource:     status
        Time:            2022-07-06T16:51:11Z
      Resource Version:  6304
      UID:               c137a6c1-7072-4afb-a12d-16b727936b13
    Spec:
      Host:             brewz.f5demo.com
      Routes:
        Action:
          Pass:  spa
        Matches:
          Action:
            Pass:  spa-dark
          Conditions:
            Cookie:  app_version
            Value:   dark
        Path:        /
        Action:
          Pass:  api
        Path:    /api
        Policies:
          Name:  rate-limit-policy
        Action:
          Proxy:
            Rewrite Path:  /api/inventory
            Upstream:      inventory
        Path:              /api/inventory
        Action:
          Proxy:
            Rewrite Path:  /api/recommendations
            Upstream:      recommendations
        Path:              /api/recommendations
        Action:
          Proxy:
            Rewrite Path:  /images
            Upstream:      api
        Path:              /images
        Upstreams:
        Name:     spa
        Port:     8080
        Service:  spa
        Name:     api
        Port:     8000
        Service:  api
        Name:     inventory
        Port:     8002
        Service:  inventory
        Name:     recommendations
        Port:     8001
        Service:  recommendations
        Name:     spa-dark
        Port:     8080
        Service:  spa-dark
    Status:
      External Endpoints:
        Ip:     10.1.1.5
        Ports:  [80,443]
      Message:  Configuration for default/brewz was added or updated
      Reason:   AddedOrUpdated
      State:    Valid
    Events:     <none>
    ```

    A few items of interest in the output:

    - Spec.Routes.Action:
      - "/" -> spa
      - "/" with cookie `app_version=dark` -> spa-dark
      - "/api" -> api
        - with a policy named rate-limit-policy
      - "/images" -> rewrite policy to the api upstream
      - "/api/inventory" -> /api/inventory of inventory service
      - "/api/recommendations" -> /api/recommendations of recommendations service

## Next Steps

Now that you have a base application deployed, let's take a deeper look at the [VirtualServer resource](virtualserver.md).
