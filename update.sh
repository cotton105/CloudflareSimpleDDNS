#!/bin/bash
##########################################################################
# This is intended to be set up as a cron job.
# It will periodically check whether the public IP has changed, and update
# Cloudflare accordingly.
##########################################################################

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
api_config_file="$script_dir/api.conf"
cache_file="$script_dir/cached_ip.txt"

function initialize_config () {
    cat > $api_config_file<< EOF
API_TOKEN=
API_ZONE_ID=
API_RECORD_ID=
DOMAIN_NAME=
PROXIED=
EOF
}

if [ ! -f $api_config_file ]; then
    initialize_config
fi
source $api_config_file
if [ -z $API_TOKEN ] || [ -z $API_ZONE_ID ] || [ -z $API_ACCOUNT_ID ] || [ -z $DOMAIN_NAME ] || [ -z $PROXIED ]; then
    echo API details must be specified in api.conf.
    exit 1
fi

if [ ! -f $cache_file ]; then
    touch $cache_file
fi

current_ip="$(curl -s ifconfig.co)"
cached_ip="$(cat $cache_file)"

if [ "$current_ip" != "$cached_ip" ]; then
    echo "Cached address ($cached_ip) doesn't match actual address ($current_ip). Checking Cloudflare..."
    cloudflare_details_raw=$(curl --silent \
        --request GET \
        --url https://api.cloudflare.com/client/v4/zones/$API_ZONE_ID/dns_records/$API_RECORD_ID \
        --header "Content-Type: application/json" \
        --header "Authorization: Bearer $API_TOKEN")
    cloudflare_details_json=$(echo $cloudflare_details_raw | jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]")
    cloudflare_ip=$(echo $cloudflare_details_json | grep -Po '(?<="content":")[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*')
    if [ "$current_ip" == "$cloudflare_ip" ]; then
        echo "Cloudflare address is correct. Update will be skipped."
        echo $current_ip > $cache_file
        exit 0
    fi
    echo "Cloudflare address ($cloudflare_ip) is outdated. Updating..."
    curl --silent \
        --request PUT \
        --url "https://api.cloudflare.com/client/v4/zones/$API_ZONE_ID/dns_records/$API_RECORD_ID" \
        --header "Content-Type: application/json" \
        --header "Authorization: Bearer $API_TOKEN" \
        --data "{
            \"content\": \"$current_ip\",
            \"name\": \"$DOMAIN_NAME\",
            \"proxied\": $PROXIED,
            \"type\": \"A\",
            \"comment\": \"Updated by AutoDNSUpdate on $(date)\",
            \"ttl\": 1
        }"
    echo $current_ip > $cache_file
fi
