## About
This is a script to automatically update your **Cloudflare** domain to point to your own public IPv4 address.

## Usage
Upon running the script for the first time, it will generate `api.conf` for the details for your domain, which looks like this:
```
API_TOKEN=
API_ZONE_ID=
API_RECORD_ID=
DOMAIN_NAME=
PROXIED=
```

### Variable details
#### `API_TOKEN`
An API token for interacting with the Cloudflare API. You can generate one [here](https://dash.cloudflare.com/profile/api-tokens).

At minimum, you need the **DNS:Edit** permission for the **Zone** you intend to update.

#### `API_ZONE_ID`
The **Zone ID** for your domain. You can find this on your Cloudflare dashboard, if you go to Websites -> *your domain*

#### `API_RECORD_ID`
The ID of the record that will be updated. Find this with the following command:
```bash
curl --request GET \
  --url https://api.cloudflare.com/client/v4/zones/[API_ZONE_ID]/dns_records \
  --header 'Content-Type: application/json' \
  --header 'Authorization: Bearer [API_TOKEN]'
```

#### `DOMAIN_NAME`
Your domain name.

#### `PROXIED`
Whether to use Cloudflare's proxying service on the record.
