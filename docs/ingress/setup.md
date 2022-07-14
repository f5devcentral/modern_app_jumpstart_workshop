
# Setup

For this lab, you will start with a clean environment and build out your K3s environment.

## Uninstall K3s in UDF

SSH into the K3s server using the UDF *SSH* or *Web Shell* Access Methods and run the following commands:

```bash
sudo su -
/usr/local/bin/k3s-uninstall.sh
```

## Install K3s in UDF

For this lab we will leverage the Rancher K3s Kubernetes distribution.  Since we plan to use NGINX Plus as our ingress controller we will also tell K3s not to install Traefik as the default ingress.

Run the following command on the K3s server:

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--no-deploy traefik --egress-selector-mode=disabled --bind-address 10.1.1.5" sh -s -
```

## Generate Service Account

To provide remote Access to the K8s API, the best practice would be to generate a dedicated K8s Service Account.

Run the following commands on the K3s server:

```bash
kubectl -n kube-system create serviceaccount udf-sa
kubectl create clusterrolebinding udf-sa-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:udf-sa
TOKENNAME=`kubectl -n kube-system get serviceaccount/udf-sa -o jsonpath='{.secrets[0].name}'`
echo $TOKENNAME
TOKEN=`kubectl -n kube-system get secret $TOKENNAME -o jsonpath='{.data.token}' | base64 --decode`
echo $TOKEN
```

## Generate Local Kubeconfig

Now that we have K3s up and running and a dedicated service account for UDF we need to build a kubeconfig file so *kubectl* on your laptop knows how to access our cluster.

*Note:* the `kubectl config` command will produce warnings about invalid configuration - this can be ignored since you are building the configuration.

1. Run the following commands on the K3s server:

    ```bash
    NEWCFG=/etc/rancher/k3s/config-udf.yaml

    # Get the UDF Access Method
    HOST=`curl -s metadata.udf/deployment | jq '.deployment.components[] | select(.name == "k3s") | .accessMethods.https[] | select(.label == "K3s API") | .host' -r`

    # Get the UDF Access Method's CA
    CA=`openssl s_client -connect $HOST:443 2>&1 </dev/null | sed -ne '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p'|base64 -w 0`

    # Ensure the Kubernetes API is up
    while ! kubectl get po
    do
        echo waiting for kube api to be up...
        sleep 10
    done

    # Add the UDF K8s API 
    kubectl --kubeconfig=$NEWCFG config set-cluster udf  --server=https://$HOST:443 
    kubectl --kubeconfig=$NEWCFG config set clusters.udf.certificate-authority-data $CA

    # set the token
    TOKENNAME=`kubectl -n kube-system get serviceaccount/udf-sa -o jsonpath='{.secrets[0].name}'`
    TOKEN=`kubectl -n kube-system get secret $TOKENNAME -o jsonpath='{.data.token}' | base64 --decode`
    kubectl --kubeconfig=$NEWCFG config set-credentials udf-sa --token=$TOKEN

    # Set context
    kubectl --kubeconfig=$NEWCFG config set-context udf --cluster=udf --namespace=default --user=udf-sa

    # Set current context
    kubectl --kubeconfig=$NEWCFG config set current-context udf

    # Display kubeconfig file
    cat $NEWCFG
    ```

1. Copy the output from the kubeconfig file and save it to your laptop.

1. Set the `KUBECONFIG` environment variable to your new kubeconfig file:

    ```bash
    # Export kubeconfig location
    export KUBECONFIG=~/Downloads/config-udf.yaml

    # Test kubeconfig, you should see the k3s node
    kubectl get nodes
    ```

# Fork Infrastructure Repository
When practicing GitOps with Argo CD, it is a [good practice](https://argo-cd.readthedocs.io/en/stable/user-guide/best_practices/) to separate your application code from your infrastructure configuration into separate repositories. This will ensure that changes to either may occur in isolation without triggering a large-scale deployment. You will fork a secondary repository to your own GitHub account as you did earlier.

You can complete this task through the GitHub UI: 
![GitHub Fork](../assets/gh_fork_infra.png)

or via the GitHub CLI:

```bash
gh repo clone f5devcentral/modern_app_jumpstart_workshop_infra
```

## Clone your workshop infrastructure repository to your laptop
Now that you have forked the workshop infrastructure repository, you'll want to clone the repo to your local laptop. You can do this via the git or GitHub CLI commands.

**Note:** Make sure to replace your_username with your GitHub username.
**Note:** If you have not [configured GitHub authentication](https://docs.github.com/en/authentication) with your local laptop, please stop and do that now.

Git:
```bash
# via HTTPS
git clone https://github.com/your_username/modern_app_jumpstart_workshop_infra.git modern_app_jumpstart_workshop_infra

# via SSH
git clone git@github.com:your_username/modern_app_jumpstart_workshop_infra.git modern_app_jumpstart_workshop_infra
```

**Note:** For the remainder of this lab, we will refer to this repository as **"infra"**.

# Next Steps

Next, we will [install Argo CD](argocd.md)
