# Install Prometheus via ArgoCD

In this step, you will use GitOps to install Prometheus leveraging ArgoCD.

## Update ArgoCD Application Manifest

You will need to update the Prometheus ArgoCD manifest to match your environment.

1. Open the `manifests/prometheus-subchart.yaml` file in your forked version of the **infra** repository.

1. Find the following variables and replace them with your information:

    | Variable        | Value                |
    |-----------------|----------------------|
    | \<GITHUB_USER\> | your github username |

    Your file should look similar to the example below:

    ```yaml
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: prometheus
      namespace: argocd
      finalizers:
        - resources-finalizer.argocd.argoproj.io
    spec:
      project: default
      source:
        path: charts/prometheus
        repoURL: https://github.com/codygreen/modern_app_jumpstart_workshop_infra.git
        targetRevision: HEAD
      destination:
        namespace: monitoring
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

1. Stage the changes, and commit to your local **infra** repository.

1. Push the changes to your remote **infra** repository.

## Deploy the manifest

1. To deploy the Prometheus ArgoCD application, run the following command:

    ```bash
    kubectl apply -f manifests/prometheus-subchart.yaml
    ```

## Verify Install

You should now see a new Prometheus application in your ArgoCD dashboard. Click on the Prometheus application and verify there are no errors.

## Next Steps

Next, you will [install Grafana](install_grafana.md)
