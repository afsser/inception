FROM debian:bullseye 
RUN apt update && apt upgrade -y && apt install -y nginx openssl
RUN mkdir -p /etc/nginx/certs

COPY tools/generate-cert.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/generate-cert.sh

COPY conf/nginx.conf /etc/nginx/sites-available/default
ENTRYPOINT ["/usr/local/bin/generate-cert.sh"]