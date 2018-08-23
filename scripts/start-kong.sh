#!/bin/bash
set -e
source color.sh
source /etc/profile.d/rvm.sh

bold "Waiting for SQL connection to be available..."
/usr/local/bin/wait-for.sh $KONG_PG_HOST:5432

bold "Running migrations..."
kong migrations up

bold "Starting kong..."
kong prepare -p "/usr/local/kong"
/usr/local/openresty/nginx/sbin/nginx -c /usr/local/kong/nginx.conf -p /usr/local/kong/

$@
