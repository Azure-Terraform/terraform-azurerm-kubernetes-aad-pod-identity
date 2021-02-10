#!/bin/bash
apt-get update
apt-get install -y jq
export ACCESS_TOKEN=$(curl -s 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fstorage.azure.com%2F' -H Metadata:true | jq -r '.access_token')
curl -s {{ .Values.url }} -H "x-ms-version: 2017-11-09" -H "Authorization: Bearer $ACCESS_TOKEN" -o /usr/share/nginx/html/index.html
nginx -g 'daemon off;'
