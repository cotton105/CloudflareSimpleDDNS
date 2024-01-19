#!/bin/bash
##########################################################################
# This is intended to be set up as a cron job.
# It will periodically check whether the public IP has changed, and update
# Cloudflare accordingly.
##########################################################################

api_config_file='api.conf'
if [ ! -f $api_config_file ]; then
    cat > $api_config_file<< EOF
API_EMAIL=
API_KEY=
EOF
fi
source $api_config_file
if [ -z $API_EMAIL -o -z $API_KEY ]; then
    echo API details must be specified in api.conf.
    exit 1
fi

cache_file='cached_ip.txt'
if [ ! -f $cache_file ]; then
    touch $cache_file
fi

current_ip="$(curl -s ifconfig.co)"
cached_ip="$(cat $cache_file)"

if [ $current_ip != $cached_ip ]; then
    echo run api command!
    echo $current_ip > $cache_file
else
    echo "don't run api command!"
fi

echo ifconfig: $current_ip
echo cached: $cached_ip
