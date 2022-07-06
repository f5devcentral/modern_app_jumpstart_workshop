#!/bin/bash
PWD=/root/modern_app_jumpstart_workshop/setup

# get latest version of scripts
cd $PWD
git fetch
git pull

# Check if systemctl service is installed 
if ! systemctl list-units --full -all | grep -Fq "udf-setup.service"; then
  cp $PWD/services/udf-setup.service /etc/systemd/system/
  systemctl daemon-reload
  systemctl enable udf-setup
  systemctl start udf-setup
fi

# Setup the gen_kubeconfig script
$PWD/scripts/gen_kubeconfig.sh

# install manifests
$PWD/scripts/manifests.sh

# setup nginx
$PWD/scripts/nginx.sh