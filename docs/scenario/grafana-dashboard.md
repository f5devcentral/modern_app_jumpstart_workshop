# Install the Grafana dashboard for NGINX

The NGINX Ingress Controller provides a Grafana dashboard to provide analytical data related to the performance and behavior of the controller's underlying NGINX metrics. The NGINX Ingress Controller has been installed with support for providing these metrics in the Prometheus format, and we will leverage Grafana to consume these metrics, and provide a visual representation of this data.

Grafana has been pre-installed using Helm based on [this guidance](https://github.com/grafana/helm-charts), and its service has been exposed in the k8s cluster via NodePort, and accessible in a UDF access method.

1. Click on the **Grafana** access method in the **k3s** component in the UDF deployment. 

1. When presented for login credentials, enter `admin` as the username. To acquire the password, you must interrogate k8s for the secret containing the password:

```bash
 kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

1. Clone the NGINX Ingress Controller repository to your local machine:

```bash
git clone https://github.com/nginxinc/kubernetes-ingress.git --branch v2.2.2
cd kubernetes-ingress/grafana
```

1. Once logged in, click the **New Dashboard** button and click Import.
Upload NGINXPlusICDashboard.json or copy and paste the contents of the file in the text box and click Load.

1. Set the Prometheus data source and click Import.
The dashboard will appear. Note how you filter metrics per namespace, per replica name and also per NGINX server zone, server and upstream server (top left corner).