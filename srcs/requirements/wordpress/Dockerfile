FROM debian:bullseye
RUN apt update && apt upgrade -y && apt install -y php-fpm vim



# REMOVE tail -f AFTER TESTING !!!
ENTRYPOINT ["tail", "-f", "/dev/null"]