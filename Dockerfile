FROM debian:buster

ENV DEBIAN_FRONTEND noninteractive

# install NGINX
RUN apt-get update && \
	apt-get install -y nginx --no-install-recommends && \
	rm -rf /var/lib/apt/lists/*

# install
RUN apt-get update
RUN apt-get install -y \
     git \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg\
	 webp libwebp-dev \
     software-properties-common 

RUN rm -rf /var/lib/apt/lists/*

RUN curl https://packages.sury.org/php/apt.gpg | apt-key add -
RUN echo 'deb https://packages.sury.org/php/ buster main' > /etc/apt/sources.list.d/deb.sury.org.list

# php8
RUN apt-get update && \
       apt-get install -y php8.1-fpm php8.1-cli php8.1-common php8.1-opcache php8.1-curl php8.1-mbstring php8.1-zip php8.1-imagick php8.1-xml php8.1-gd php8.1-pgsql php8.1-mysql php8.1-pdo --no-install-recommends && \
       rm -rf /var/lib/apt/lists/*

# verify versions
RUN php -v

RUN useradd -ms /bin/bash nginx

# php-redis install
RUN apt-get update && \
	apt-get install -y php-redis --no-install-recommends && \
	rm -rf /var/lib/apt/lists/*

# Composer installation.
RUN curl -sS https://getcomposer.org/installer | php 
RUN mv composer.phar /usr/local/bin/composer && chmod +x /usr/local/bin/composer

# supervisory
RUN apt-get update && \
	apt-get install -y supervisor --no-install-recommends && \
	rm -rf /var/lib/apt/lists/*
COPY ops/supervisor.conf /etc/supervisor/supervisord.conf
RUN mkdir /run/php 

COPY ops/www.conf /etc/php/8.1/fpm/pool.d/
COPY ops/php8proxy /etc/nginx/php8proxy
COPY ops/nginx.conf /etc/nginx/
COPY ops/apps.conf /etc/nginx/conf.d/apps.conf
COPY ops/php.ini /etc/php/8.1/fpm/

#apps
RUN mkdir /var/www/apps
#COPY . /var/www/apps/
#WORKDIR /var/www/apps
#RUN composer install && chmod 777 -Rf storage

WORKDIR /var/www/apps

EXPOSE 8888

CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]

