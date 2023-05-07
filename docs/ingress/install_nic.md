# Install NGINX Plus Ingress

For this step, we will pull the NGINX Plus Ingress Controller image from your private registry and deploy it into your K3s deployment.

We will use ArgoCD to deploy NGINX Ingress Controller for us. However, if you wanted to do this using the Helm CLI, you may use [this procedure](install_nic_helm.md) as a reference.

Alternatively, if you wish to install the NGINX Ingress Controller from the NGINX private container registry, you can follow [this procedure](install_nic_nginx_registry.md) and skip the remainder of this document.

> **Note:** For more details, you can access the NGINX Ingress Controller documentation [here](https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-helm/)

## Create a Read-Only GitHub PAT (Personal Access Token)

While you could leverage the PAT created in the build steps, the best practice is to leverage a least privilege model and create a read-only PAT for your Kubernetes cluster.

1. Create a [GitHub PAT (Personal Access Token)](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) with the following scopes:
    - *read:packages*

1. Export the value to the *GITHUB_TOKEN* environment variable.

    ```bash
    export GITHUB_TOKEN=your_access_token
    ```

## Create Kubernetes Secret

1. In order to pull the NGINX Plus Ingress container from your private registry, the K8s cluster will need to have access to the GitHub PAT you created previously. To accomplish this, you will create a docker-registry secret with the commands below:

    ```bash
    # Create nginx-ingress namespace
    kubectl create namespace nginx-ingress

    # Replace your_github_username with your Github username
    export GITHUB_USER=your_github_username

    # create container registry secret
    kubectl create secret docker-registry ghcr -n nginx-ingress --docker-server=ghcr.io --docker-username=${GITHUB_USER} --docker-password=${GITHUB_TOKEN}
    ```

## Update Helm Values and ArgoCD Application Manifest

Before you can deploy the NGINX Ingress Controller, you will need to modify the Helm chart values to match your environment.

1. Find your NGINX Plus Ingress Controller container tag with the following command:

    ```bash
    TAG=`docker images ghcr.io/$GITHUB_USER/nginx-plus-ingress --format "{{.Tag}}"`
    echo $TAG
    ```

    > **Note:** If you had previously created and tagged an `nginx-plus-ingress` container image on your system, the command above used to set the `TAG` variable will not work. Instead, run `docker images ghcr.io/$GITHUB_USER/nginx-plus-ingress --format "{{.Tag}}"` and select your most recent tag from the output, then set the variable manually: `TAG=<your tag from the previous command>`.

1. Open the `charts/nginx-plus-ingress/values.yaml` file in your forked version of the **infra** repository.

1. Find the following variables and replace them with your information:

    | Variable        | Value                           |
    |-----------------|---------------------------------|
    | \<GITHUB_USER\> | your github username            |
    | &lt;TAG>        | tag value from previous command |

    Your file should look similar to the example below:

    ```yaml
    controller:
      appprotect: 
        enable: true
      appprotectdos:
        enable: true
      enableSnippets: true
      image:
        repository: ghcr.io/codygreen/nginx-plus-ingress
        tag: 3.0.2-SNAPSHOT-a88b7fe
      nginxplus: true
      nginxStatus:
        allowCidrs: 0.0.0.0/0
        port: 9000
      readyStatus:
        initialDelaySeconds: 30
      serviceAccount:
        imagePullSecretName: ghcr
      service:
        customPorts:
          - port: 9114
            targetPort: service-insight
            nodePort: 31000
            protocol: TCP
            name: service-insight
          - port: 9000
            targetPort: 9000
            nodePort: 32000
            protocol: TCP
            name: nginx-status
    prometheus:
      create: true
    serviceInsight:
      create: true
    ```

1. Save the file. Next, you will need to update the NGINX Plus Ingress ArgoCD manifest to match your environment.  

1. Open the `manifests/nginx-ingress-subchart.yaml` file in your forked version of the **infra** repository.

1. Find the following variables and replace them with your information:

    | Variable        | Value                |
    |-----------------|----------------------|
    | \<GITHUB_USER\> | your github username |

    Your file should look similar to the example below:

    ```yaml
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: nginx-plus-ingress
      namespace: argocd
      finalizers:
        - resources-finalizer.argocd.argoproj.io
    spec:
      project: default
      source:
        path: charts/nginx-plus-ingress
        repoURL: https://github.com/codygreen/modern_app_jumpstart_workshop_infra.git
        targetRevision: HEAD
      destination:
        namespace: nginx-ingress
        server: https://kubernetes.default.svc
      syncPolicy:
        automated:
          selfHeal: true
          prune: true
        syncOptions:
          - CreateNamespace=true
          - ApplyOutOfSyncOnly=true
    ```

1. Save the file.

1. Stage both changed files, and commit them to your local **infra** repository.

1. Push the changes to your remote **infra** repository.

## Install NGINX Plus Ingress ArgoCD Application

1. Now that we have the base requirements ready, we can add the NGINX Plus Ingress application to ArgoCD with the following command:

    ```bash
    kubectl apply -f manifests/nginx-ingress-subchart.yaml
    ```

## Verify Install

Now that NGINX Plus Ingress Controller has been installed, we need to check that our pods are up and running.

## Verify Deployment

1. To check our pod run the following command:

    ```bash
    kubectl get pods -n nginx-ingress
    ```

    The output should look similar to:

    ```shell
    NAME                                                READY   STATUS    RESTARTS   AGE
    nginx-plus-ingress-nginx-ingress-7547565fbc-f8nqj   1/1     Running   0          55m
    ```

1. To check our service run the following command:

    ```bash
    kubectl get svc -n nginx-ingress
    ```

    The output should look similar to:

    ```shell
    NAME                               TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
    nginx-plus-ingress-nginx-ingress   LoadBalancer   10.43.129.144   10.1.1.5      80:31901/TCP,443:31793/TCP   57m
    ```

## Inspect Pod Details

1. Now that we know our NGINX Ingress Controller Pod is up and running, let's dig into some of the pod details.

    ```bash
    NIC_POD=`kubectl get pods -n nginx-ingress -o json | jq '.items[0].metadata.name' -r`
    kubectl describe pod $NIC_POD -n nginx-ingress
    ```

    The output should look similar to:

    ```bash
    Name:         nginx-plus-ingress-nginx-ingress-785b67bf4-vgtdl
    Namespace:    nginx-ingress
    Priority:     0
    Node:         k3s/10.1.1.5
    Start Time:   Wed, 06 Jul 2022 09:07:17 -0700
    Labels:       app=nginx-plus-ingress-nginx-ingress
                  pod-template-hash=785b67bf4
    Annotations:  prometheus.io/port: 9113
                  prometheus.io/scheme: http
                  prometheus.io/scrape: true
    Status:       Running
    IP:           10.42.0.22
    IPs:
      IP:           10.42.0.22
    Controlled By:  ReplicaSet/nginx-plus-ingress-nginx-ingress-785b67bf4
    Containers:
      nginx-plus-ingress-nginx-ingress:
        Container ID:  containerd://69e9e416438c2cc2330df627cc7605640f6c196092a4ea3f7ff421c3bcfbbcd7
        Image:         ghcr.io/codygreen/nginx-plus-ingress:3.0.2-SNAPSHOT-a88b7fe
        Image ID:      ghcr.io/codygreen/nginx-plus-ingress@sha256:6b480db30059249d90d4f2d9d8bc2012af8c76e9b25799537f4b7e5a4a2946ca
        Ports:         80/TCP, 443/TCP, 9113/TCP, 8081/TCP
        Host Ports:    0/TCP, 0/TCP, 0/TCP, 0/TCP
        Args:
          -nginx-plus=true
          -nginx-reload-timeout=60000
          -enable-app-protect=true
          -enable-app-protect-dos=true
          -app-protect-dos-debug=false
          -app-protect-dos-max-daemons=0
          -app-protect-dos-max-workers=0
          -app-protect-dos-memory=0
          -nginx-configmaps=$(POD_NAMESPACE)/nginx-plus-ingress-nginx-ingress
          -default-server-tls-secret=$(POD_NAMESPACE)/nginx-plus-ingress-nginx-ingress-default-server-tls
          -ingress-class=nginx
          -health-status=false
          -health-status-uri=/nginx-health
          -nginx-debug=false
          -v=1
          -nginx-status=true
          -nginx-status-port=9000
          -nginx-status-allow-cidrs=0.0.0.0/0
          -report-ingress-status
          -external-service=nginx-plus-ingress-nginx-ingress
          -enable-leader-election=true
          -leader-election-lock-name=nginx-plus-ingress-nginx-ingress-leader-election
          -enable-prometheus-metrics=true
          -prometheus-metrics-listen-port=9113
          -prometheus-tls-secret=
          -enable-service-insight=true
          -enable-custom-resources=true
          -enable-snippets=true
          -enable-tls-passthrough=false
          -enable-preview-policies=false
          -enable-cert-manager=false
          -enable-oidc=false
          -ready-status=true
          -ready-status-port=8081
          -enable-latency-metrics=false
        State:          Running
          Started:      Mon, 20 Mar 2023 13:18:56 -0700
        Ready:          True
        Restart Count:  0
        Readiness:      http-get http://:readiness-port/nginx-ready delay=30s timeout=1s period=1s #success=1 #failure=3
        Environment:
          POD_NAMESPACE:  nginx-ingress (v1:metadata.namespace)
          POD_NAME:       nginx-plus-ingress-nginx-ingress-785b67bf4-vgtdl (v1:metadata.name)
        Mounts:
          /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-tp2v4 (ro)
    Conditions:
      Type              Status
      Initialized       True
      Ready             True
      ContainersReady   True
      PodScheduled      True
    Volumes:
      kube-api-access-tp2v4:
        Type:                    Projected (a volume that contains injected data from multiple sources)
        TokenExpirationSeconds:  3607
        ConfigMapName:           kube-root-ca.crt
        ConfigMapOptional:       <nil>
        DownwardAPI:             true
    QoS Class:                   BestEffort
    Node-Selectors:              <none>
    Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                                 node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
    Events:                      <none>
    ```

    Some items of interest from the output:

    - Ports:
      - 80/443: http/https traffic
      - 8081: readiness
      - 9113: Prometheus

## NGINX Dashboard

The NGINX Plus Ingress Controller includes the NGINX dashboard that reports key load-balancing and performance metrics. When you deployed Ingress Controller, `customPorts` were specified in the values file. These were added so the dashboard could be exposed as a service and available to use external to the cluster.

1. To access the dashboard, open the **NGINX Dashboard** UDF Access Method on the k3s component. You should see the NGINX default welcome page.

1. Append `/dashboard.html` to the URL in your browser to see the NIGNX Plus dashboard.

1. Explore the features of the dashboard.

## Next Steps

Now you can [install Prometheus](install_prometheus.md).
