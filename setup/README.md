# UDF Lab Setup

This folder contains the resources needed to build and maintain the base UDF blueprint for this lab.

## Manifests

The manifest folder contains manifests that need to be copied to the
`/var/lib/rancher/k3s/server/manifests` folder on the k3s server.

To configure setup on a new k3s server, run the following steps:

```bash
git clone https://github.com/f5devcentral/modern_app_jumpstart_workshop.git
cp /root/modern_app_jumpstart_workshop/setup/manifests/* /var/lib/rancher/k3s/server/manifests
```

You can check the logs by:

```bash
journalctl -u k3s.service
```
