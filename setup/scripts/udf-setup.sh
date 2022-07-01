#!/bin/bash
PWD=/root/modern_app_jumpstart_workshop/setup/scripts
# get latest version of scripts
git pull

# Setup the gen_kubeconfig script
$PWD/gen_kubeconfig.sh

# install manifests
$PWD/manifests.sh