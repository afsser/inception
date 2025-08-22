FROM debian:bullseye 
RUN apt update && apt upgrade -y && apt install -y nginx
COPY conf/nginx.conf /etc/nginx/sites-available/default
ENTRYPOINT ["nginx", "-g", "daemon off;"]