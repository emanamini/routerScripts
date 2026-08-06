### Preparing Caddy
To ensure the app functions flawlessly, we require a valid `ssl` certificate and a domain connected to Cloudflare. You can skip this section, but acquiring a cheap or even free domain with customizable DNS records is well worth it. In this tutorial, we assume the domain `ilola.ir` is designated for this task. Replace it with your own domain in the configurations below. Go to Cloudflare and connect your domain. I provided a brief explanation on this in the [[#Creating a Custom Stamp]] section. 
On the [Cloudflare main page](https://dash.cloudflare.com), navigate to the left menu, select the `Domains` section, and then `Overview`. Select your previously added domain. Now, from the left panel, select `DNS` and then `Records`. Click the blue `Add record` button. Set the `Type` to `A`. In the `Name` field, enter the `@` character. In the `IPv4 address` field, enter your `lan` IP address, which is `172.22.0.1`. The `Proxy Status` toggle should automatically turn off. If it doesn't, turn it off manually. Click the blue `Add record` button again and repeat the previous steps, with the exception that in the `Name` field, enter `www` instead of `@` to create a new record. We now have two records tied to the `lan` IP—one pointing to the root address and the other pointing to the `www` address. Let's proceed to the next Cloudflare setting. Return to the main [dashboard](https://dash.cloudflare.com) page.

To acquire an API token, scroll down the sidebar to `Manage account`. Then, from the expanded menu, select `Account API tokens`. Click the blue `Create token` button. On the resulting page, under `Edit policy`, open the dropdown menu and change it from `Entire account` to `Specified Domains`. An option will appear next to it. Select the domain you designated for Caddy. Scroll down slightly and open `DNS & Zones`. Check the `Read` and `Edit` boxes next to `DNS`, and check the `Read` box next to `Zone`. Scroll to the bottom of the page and click the blue `Review token` button. On the next page, you should see something resembling this:
```text
ilola.ir in
e**********ni@gmail.com's Account

DNS Read
DNS Write
Zone Read
```
Now click the blue `Create token` button. An `API` key will be generated for you. Save it immediately in a secure location because it will only be displayed once. The key typically begins with the string `cfat`.

Now we will fetch the Caddy binary (`caddy`) for the system using these commands and relocate it to the proper directory:
```bash
curl -sL "https://caddyserver.com/api/download?os=linux&arch=amd64&p=github.com%2Fcaddy-dns%2Fcloudflare" -o caddy

sudo mv caddy /usr/local/bin/caddy

sudo chmod +x /usr/local/bin/caddy
```
Next, we will modify the Caddy service:
```bash
sudo systemctl edit caddy.service
```
There are two lines in the file that opens. One is near the top, and the other is slightly further down:
```text
### Anything between here and the comment below will become the contents of the drop-in file  
   
### Edits below this comment will be discarded
```
The configurations below MUST be placed exactly between these two lines, otherwise, they will be ignored:
```ini
### Anything between here and the comment below will become the contents of the drop-in file  
  
[Unit]  
After=network-online.target arch-portal.service  
Wants=network-online.target arch-portal.service  
StartLimitIntervalSec=60s  
StartLimitBurst=10  
  
[Service]  
# 1. Clear and override the Validation pre-check  
ExecStartPre=  
ExecStartPre=/usr/local/bin/caddy validate --config /etc/caddy/Caddyfile  
  
# 2. Clear and override the Main startup command  
ExecStart=  
ExecStart=/usr/local/bin/caddy run --environ --config /etc/caddy/Caddyfile  
  
Restart=on-failure  
RestartSec=5s  
  
### Edits below this comment will be discarded
```
This service requires the [[#VPN Portal]] as a dependency, which we will build in a few minutes. Next up is the Caddy file. Open it with nano:
```bash
sudo nano /etc/caddy/Caddyfile
```
The values below belong to my file. Treat them as a template. You must modify them according to your own variables:
```text
{
    admin "unix//run/caddy/admin.socket"
}
# 1. The Real Domain (Uses Cloudflare DNS Challenge for valid SSL!)
ilola.ir, www.ilola.ir {
    tls {
        dns cloudflare cfat_XXXXXXXX
    }
    reverse_proxy 127.0.0.1:8080
}
# 2. Pure HTTP for the Fallback IPs
http://172.22.0.1 {
    reverse_proxy 127.0.0.1:8080
}
# 3. Forced HTTPS for the Fallback IPs
https://172.22.0.1 {
    tls internal
    reverse_proxy 127.0.0.1:8080
}
```
You must replace both site names and the `API` key with your respective values. With this configuration, the portal interface becomes accessible over port 80 on the `lan` IP.

If you bypassed the Cloudflare domain registration steps, you must comment out the entirety of block 1 by placing `#` symbols at the start of its lines down to `# 2`. If you do this, your portal will throw an `ssl` error during runtime and may prevent you from installing it as a standalone app. The beauty of purchasing a domain, connecting it to Cloudflare, and applying the aforementioned configurations is precisely this automatic retrieval of a valid `ssl` certificate. 

If you configured Cloudflare, it is time for `dnsmasq` to act as the bridge between the domain address and the service. Open its config file and insert the following line among the settings:
```bash
sudo nano /etc/dnsmasq.conf
```
```text
address=/ilola.ir/172.22.0.1
```
