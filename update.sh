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
API_ZONE_ID=
API_ACCOUNT_ID=
DOMAIN_NAME=
PROXIED=
EOF
fi
source $api_config_file
if [ -z $API_EMAIL ] || [ -z $API_KEY ] || [ -z $API_ZONE_ID ] || [ -z API_ACCOUNT_ID ] || [ -z DOMAIN_NAME ] || [ -z PROXIED ]; then
    echo API details must be specified in api.conf.
    exit 1
fi

cache_file='cached_ip.txt'
if [ ! -f $cache_file ]; then
    touch $cache_file
fi

current_ip="$(curl -s ifconfig.co)"
cached_ip="$(cat $cache_file)"

if [ "$current_ip" != "$cached_ip" ]; then
    echo run api command!
    curl --request PUT \
        --url "https://api.cloudflare.com/client/v4/zones/$API_ZONE_ID/dns_records/$API_ACCOUNT_ID" \
        --header "Content-Type: application/json" \
        --header "X-Auth-Email: $API_EMAIL" \
        --header "X-Auth-Key: $API_KEY" \
        --data "{
            'content': '$current_ip',
            'name': '$DOMAIN_NAME',
            'proxied': $PROXIED,
            'type': 'A',
            'comment': 'Updated by AutoDNSUpdate on $(date)',
            'ttl': 1
        }"
    echo $current_ip > $cache_file
else
    echo "don't run api command!"
fi

echo ifconfig: $current_ip
echo cached: $cached_ip
