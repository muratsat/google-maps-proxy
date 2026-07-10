# Requirements

- nginx
- jq

# 1. Setup env

write to `.env` file:

```
GMAPS_API_KEY=abc123
```

# 2. Setup crontab

```
0 0 * * 0 <cloned-location>/update-session-token.sh /etc/nginx/sites-available/gmaps_secrets.conf && systemctl reload nginx
```

# 3. add nginx config for google maps proxy:

```nginx
server {
    listen 80;
    server_name <server_name>;

    # Values defined in gmaps_secrets.conf:
    #   set $gmaps_api_key "abc123";
    #   set $gmaps_session "xyz789";
    include /etc/nginx/sites-available/gmaps_secrets.conf;

    resolver 8.8.8.8 valid=300s;
    resolver_timeout 10s;

    location ~ ^/v1/2dtiles/(?<z>\d+)/(?<x>\d+)/(?<y>\d+)$ {
        set $tile_upstream "tile.googleapis.com";
        set $proxy_target "https://$tile_upstream/v1/2dtiles/$z/$x/$y?session=$gmaps_session&key=$gmaps_api_key";


        proxy_ssl_server_name on;
        proxy_set_header Host $tile_upstream;

        proxy_pass $proxy_target;

    }
}
```
