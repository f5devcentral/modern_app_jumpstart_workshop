#!/bin/bash
PWD=/root/modern_app_jumpstart_workshop/setup

# copy new kubeconfig index page
echo "copying kubeconfig index page"
cp $PWD/config/kubeconfig.html /usr/share/nginx/html/


# copy config
echo "copying NGINX config"
cp $PWD/config/default.conf /etc/nginx/conf.d/default.conf

# test NGINX config
echo "testing NGINX config"
nginx -t

# restart nginx
echo "restarting NGINX"
systemctl restart nginx

nginx -T
