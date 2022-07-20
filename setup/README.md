# UDF Lab Setup

This folder contains the resources needed to build and maintain the base UDF blueprint for this lab.

After initial setup, the script will pull the latest version of the repo and copy the necessary files
for each service.  This helps avoid the need to nominate new UDF blueprint versions.

## Initial Setup

Clone the Modern App Jumpstart Workshop repository to the /root folder

```bash
cd /root
git clone https://github.com/f5devcentral/modern_app_jumpstart_workshop.git
/root/modern_app_jumpstart_workshop/setup/scripts/udf-setup.sh
```

## Config

Contains configuration files for services like NGINX

## Manifests

The manifests folder contains manifests that need to be copied to the
`/var/lib/rancher/k3s/server/manifests` folder on the k3s server.

## Services

These are systemd services
