#!/bin/bash
PWD=/root/modern_app_jumpstart_workshop/setup

# copy manifests to K3s manifest folder
cp $PWD/manifests/* /var/lib/rancher/k3s/server/manifests/
