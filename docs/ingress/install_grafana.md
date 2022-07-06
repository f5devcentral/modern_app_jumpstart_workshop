# Install Grafana via Argo CD

In this step, you will use GitOps to install Grafana leveraging Argo CD.

## Update Argo CD Application Manifest

You will need to update the Grafana Argo CD manifest to match your environment.  

1. Open the *manifests/grafana-subchart.yml* file in your forked version of the repository.
2. Find the following variables and replace them with your information:

    | Variable        | Value           |
    |-----------------|-----------------|
    | <GITHUB_USER>   | github username |

Your file should look similar to the example below:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: grafana
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    path: charts/grafana
    repoURL: https://github.com/codygreen/modern_app_jumpstart_workshop.git
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
```

## Deploy the manifest

To deploy the Grafana Argo CD application, run the following command:

```bash
kubectl apply -f manifests/grafana-subchart.yml
```

## Verify Install

You should now see a new Grafana application in your Argo CD dashboard.  Click on the Grafana application and verify there are no errors.

## Next Steps

Next, you will [install the Brewz Application](brewz.md)
