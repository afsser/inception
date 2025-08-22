#!/bin/bash

# Generate SSL certificate with environment variables
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/certs/nginx-selfsigned.key \
    -out /etc/nginx/certs/nginx-selfsigned.crt \
    -subj "/C=${CERT_COUNTRY}/ST=${CERT_STATE}/L=${CERT_CITY}/O=${CERT_ORG}/OU=${CERT_OU}/CN=${DOMAIN_NAME}"

chmod 600 /etc/nginx/certs/nginx-selfsigned.key
chmod 644 /etc/nginx/certs/nginx-selfsigned.crt

# Start nginx
exec nginx -g "daemon off;"