#!/bin/bash

##########################################################################
# This is intended to be set up as a cron job.
# It will periodically check whether the public IP has changed, and update
# Cloudflare accordingly.
##########################################################################

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
sleep 1s
