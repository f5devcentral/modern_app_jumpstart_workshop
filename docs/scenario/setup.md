# Setup
To start the monolith to microservices senario you will first need to ensure the following items are installed on your laptop:

- [Visual Studio Code](https://code.visualstudio.com/)
- [git](https://git-scm.com/downloads)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [GitHub CLI - optional](https://cli.github.com/)

## Fork the workshop repository
To proceed with this senario, you will need to fork the workshop repository to your GitHub account.  If this is your first time, then take a few minutes to review the [GitHub Docs on how to Fork a repo](https://docs.github.com/en/get-started/quickstart/fork-a-repo).

You can complete this task through the GitHub UI: 
![GitHub Fork](../assets/gh_fork.jpg)

or via the GitHub CLI:

```bash
gh repo clone f5devcentral/modern_app_jumpstart_workshop
```

## Clone your workshop repository to your laptop
Now that you have forked the workshop repository, you'll want to clone the repo to your local laptop.  You can do this via the git or GitHub CLI commands.

**Note:** Make sure to replace your_username with your GitHub username.
**Note:** If you have not [configured GitHub authentication](https://docs.github.com/en/authentication) with your local laptop, please stop and do that now.

Git:
```bash
# via HTTPS
git clone https://github.com/your_username/modern_app_jumpstart_workshop.git modern_app_jumpstart_workshop
# via SSH
git clone git@github.com:your_username/modern_app_jumpstart_workshop.git modern_app_jumpstart_workshop
```

## Generate Local Kubeconfig

To access the K8s API, you will need to download a kubeconfig file from the K3s server in your UDF blueprint.

In your UDF deployment, click the Components tab then for the k3s system click the Access dropdown then the KUBECONFIG access method.

This will present a webpage with a link to download the config-udf.yaml file.

Once the file is downloaded, set your KUBECONFIG environment variable to point to this location. For more information, reference the [K8s docs](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/#the-kubeconfig-environment-variable). 

Now, test that your settings are correct:
```bash
kubectl get nodes
```

## Manually deploy the Brewz application using manifests

```bash
cd manifests/brewz
kubectl apply -f mongo-init.yml
kubectl apply -f app.yml
kubectl apply -f virtual-server.yml
```

Use the **Brewz** UDF access method to explore the deployed app in your browser.

## Obtain the Argo CD password 
To leverage the Argo CD UI, you will need to obtain the password created at install - save this for later use. 
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

Now open the Argo CD Access Method for the K3s server and login with *admin* and the password obtain from the previous step. 