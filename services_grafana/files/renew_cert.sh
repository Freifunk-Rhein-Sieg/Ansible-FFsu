#!/bin/bash
cd /etc/ssl
# Backup meshviewer.conf
cp /etc/nginx/conf.d/meshviewer.conf nginx/conf.d/meshviewer.conf
cp nginx/conf.d/meshviewer_noredirect.conf /etc/nginx/conf.d/meshviewer.conf
/etc/init.d/nginx reload
PATH=/usr/src/simp_le/venv/bin:/usr/sbin:/usr/bin:/sbin:/bin
simp_le -v --email technik@freifunk-rhein-sieg.net -f account_key.json -f key.pem -f fullchain.pem -d map.freifunk-rhein-sieg.net:/var/www/map.fr
eifunk-rhein-sieg.net &
wait

# copy back redirecting nginx config
cp nginx/conf.d/meshviewer.conf /etc/nginx/conf.d/meshviewer.conf
echo
echo "sleeping for 30 seconds to let letzencrypt finish\n\n"
echo "..."
sleep 30
/etc/init.d/nginx reload

