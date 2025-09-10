#!/bin/bash

docker-compose exec nginx nginx -s reload
echo "Nginx reloaded"
exit 0
