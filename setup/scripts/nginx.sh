#!/bin/bash
PWD=/root/modern_app_jumpstart_workshop/setup

# copy config
cp $PWD/config/default.conf /etc/nginx/conf.d/default.conf

# restart nginx
systemctl restart nginx