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

## Configure Kubectl
For kubectl to talk with you K3s cluster in UDF, you'll need to ensure you have a kubeconfig file setup on your laptop

Download the UDF kubeconfig file from the k3s server in UDF (steps TBD)

Set the KUBECONFIG environment varible to point to your UDF kubeconfig file (see [K8s docs](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/#the-kubeconfig-environment-variable) if you need help.)

