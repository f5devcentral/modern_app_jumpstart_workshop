# Argo CD

[Argo CD](https://argoproj.github.io/cd/) is a declarative, GitOps continous delivery tool for Kubernetes.

In our workshop, we will use Argo CD to deploy our microservices and resources. 

## Install Argo CD
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

```

## Expose the Argo CD Server API/UI
Save the following manifest to argocd-nodeport.yml
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
Now, apply the manifest:
```bash
kubectl apply -f argocd-nodeport.yml
```

## Obtain the Argo CD password 

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

## Login
Use the Argo CD UDF Access Method to access the Argo CD UI and login with the `admin` user and the password you obtain in the previous step.

## Setup Your Repository and deploy Podifo in Argo CD
Save the following contents to repo.yml
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: private-repo
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: https://github.com/codygreen/argo_cd_demo
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: argo-cd-demo
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    path: podinfo
    repoURL: https://github.com/codygreen/argo_cd_demo.git
    targetRevision: HEAD
  destination:
    namespace: default
    server: https://kubernetes.default.svc
  syncPolicy:
    automated:
      selfHeal: true
      prune: true
```

Now, apply the manifest:
`kubectl apply -f repo.yml`

## Add the Podinfo Service
Save the following contents to manifests/podinfo/podinfo.yml
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: podinfo
spec:
  selector:
    matchLabels:
      app: podinfo
  template:
    metadata:
      labels:
        app: podinfo
    spec:
      containers:
      - name: podinfo
        image: stefanprodan/podinfo
        ports:
        - containerPort: 9898
---
apiVersion: v1
kind: Service
metadata:
  name: podinfo
spec:
  ports:
    - port: 80
      targetPort: 9898
  selector:
    app: podinfo
```

Commit the new file to upstream git repository.

Click on the argo-cd-demo application in the Argo CD UI, you should see the service, deploy and pod objects appear once the Argo CD sync is completed.  
![Argo CD Sync](..//assets/argo_sync.jpg)