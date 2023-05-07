# ArgoCD

[ArgoCD](https://argoproj.github.io/cd/) is a declarative, GitOps continuous delivery tool for Kubernetes.

In our workshop, we will use ArgoCD to deploy our microservices and resources.

## Install ArgoCD

1. On your laptop run:

    ```bash
    kubectl create namespace argocd
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

    ```

## Expose the ArgoCD Server API/UI

1. In your **infra** repository, save the following manifest locally to `argocd-nodeport.yaml`

    ```yml
    apiVersion: v1
    kind: Service
    metadata:
      labels:
        app.kubernetes.io/component: server
        app.kubernetes.io/name: argocd-server
        app.kubernetes.io/part-of: argocd
      name: argocd-server-nodeport
      namespace: argocd
    spec:
      ports:
        - name: http
          port: 80
          protocol: TCP
          targetPort: 8080
          nodePort: 30007
        - name: https
          port: 443
          protocol: TCP
          targetPort: 8080
          nodePort: 30008
      selector:
        app.kubernetes.io/name: argocd-server
      sessionAffinity: None
      type: NodePort
    ```

1. Now, apply the manifest:

    ```bash
    kubectl apply -f argocd-nodeport.yaml
    ```

## Login to ArgoCD

1. Obtain the ArgoCD password:

    ```bash
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
    ```

1. Use the ArgoCD UDF Access Method to access the ArgoCD UI and login with the `admin` user and the password you obtained in the previous step.

## Next Steps

Next, you will [build the NGINX Plus Ingress Controller](build_nic.md)
