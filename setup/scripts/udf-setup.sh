#!/bin/bash

# get latest version of scripts
git pull

# Setup the gen_kubeconfig script
gen_kubeconfig.sh

# install manifests
manifests.sh