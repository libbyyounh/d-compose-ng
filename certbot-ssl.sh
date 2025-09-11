#!/bin/bash

docker run --rm \
  -v "$(pwd)/certbot/etc:/etc/letsencrypt" \
  -v "$(pwd)/certbot/www:/var/www/certbot" \
  certbot/certbot \
  certonly --webroot -w /var/www/certbot \
  -d ABCD.com \
  --email your-email@example.com \
  --agree-tos \
  --no-eff-email