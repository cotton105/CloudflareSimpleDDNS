## ❗NOTICE❗
Abandoned in favour of Timothy Miller's [Cloudflare DDNS](https://github.com/timothymiller/cloudflare-ddns).

## About
This is a **Bash** script to automatically update your **Cloudflare** domain to point to your host's own public IPv4 address.

The host's actual address is queried using [ifconfig.co](https://ifconfig.co/), and if any change is detected then the DNS record is updated using Cloudflare's API.

A simple cache is used to avoid excessive queries to the Cloudflare API.

## Installation
1. Download the [latest release](https://github.com/cotton105/SimpleCloudflareDDNS/releases/latest).
2. Extract the archive to a known location, such as `/opt/`:
   ```bash
   $ mkdir /opt/auto-dns-update && tar -xvf auto-dns-update-v1.1.0.tar.gz -C /opt/auto-dns-update
   ```

## Usage
Run `update.sh` on a command line. Upon running the script for the first time, it will generate `api.conf` for the details for your domain, which looks like this:
```bash
API_TOKEN=
API_ZONE_ID=
API_RECORD_ID=
DOMAIN_NAME=
PROXIED=
```
Find more information about these variables and how they are used under [#Variable details](#variable-details).

### Automation
By itself, the script doesn't loop. You will need to run it periodically by some other means, such as with Crontab.
#### Crontab example
1. Edit your crontab:
   ```bash
   $ sudo crontab -e
   ```
2. Add the following line:
   ```
   *  *  *  *  *  <script_directory>/update.sh
   ```
   This will run the script once every minute.

Note that automated access to [ifconfig.co](https://ifconfig.co/) is rate-limited to 1 request/minute, so avoid running the script more often than this.

### <a name="variable-details"></a> Variable details
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
Read more on the [Cloudflare API Docs](https://developers.cloudflare.com/api/operations/dns-records-for-a-zone-list-dns-records).

#### `DOMAIN_NAME`
Your domain name.

#### `PROXIED`
Whether to use Cloudflare's proxying service on the record.
