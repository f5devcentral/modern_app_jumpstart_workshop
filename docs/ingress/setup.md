
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
To provide remote Access to the K8s API, best practice would be to generated a dedicated K8s Service Account. 

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

*Note:* the *kubectl config* command will produce warnings about invalid configuration - this can be ingored since you are building the configuration.

1. Run the following commands on the K3s server:
    ```bash
    export KUBECONFIG=/etc/rancher/k3s/config-udf.yaml

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
    kubectl config set-cluster udf  --server=https://$HOST:443 
    kubectl config --kubeconfig=$KUBECONFIG set clusters.udf.certificate-authority-data $CA

    # set the token
    TOKENNAME=`kubectl -n kube-system get serviceaccount/udf-sa -o jsonpath='{.secrets[0].name}'`
    TOKEN=`kubectl -n kube-system get secret $TOKENNAME -o jsonpath='{.data.token}' | base64 --decode`
    kubectl config --kubeconfig=$KUBECONFIG set-credentials udf-sa --token=$TOKEN

    # Set context
    kubectl config set-context udf --cluster=udf --namespace=default --user=udf-sa

    # Set current context
    kubectl config set current-context udf

    # Display kubeconfig file
    cat $KUBECONFIG
    ```


1. Copy the output from the kubeconfig file and save it to your laptop.
1. Set the KUBECONFIG environment variable to your new kubeconfig file
    ```bash
    # 
    export KUBECONFIG=~/Downloads/config-udf.yaml

    # Test kubeconfig, you should see the ubuntu node
    kubectl get nodes
    ```

# Next Steps
Now you can build the [NGINX Plus Ingress Controller container](build_nic.md)