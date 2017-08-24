#!/usr/bin/env bash

########################
#    重启服务           #
########################

echo "`date +"%Y-%m-%d %H:%M:%S"` Info：start reload nginx"

/usr/local/openresty/nginx/sbin/nginx -s reload