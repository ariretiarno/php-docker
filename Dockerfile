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

# php7.4
RUN apt-get update && \
	apt-get install -y php7.4-fpm php7.4-cli php7.4-common php7.4-opcache php7.4-curl php7.4-mbstring php7.4-zip php7.4-xml php7.4-gd php7.4-pgsql php7.4-pdo php7.4-json php7.4-mysql --no-install-recommends && \
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
COPY supervisor.conf /etc/supervisor/supervisord.conf
RUN mkdir /run/php 

COPY www.conf /etc/php/7.4/fpm/pool.d/
COPY php7proxy /etc/nginx/php7proxy
COPY nginx.conf /etc/nginx/
COPY apps.conf /etc/nginx/conf.d/apps.conf
COPY php.ini /etc/php/7.4/fpm/

#apps
RUN mkdir /var/www/apps
#COPY . /var/www/apps/
#WORKDIR /var/www/apps
#RUN composer install && chmod 777 -Rf storage

WORKDIR /var/www/apps

EXPOSE 8888

CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]

