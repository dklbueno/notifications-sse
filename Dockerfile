FROM php:8.1-fpm

ARG ROOT=/app
ARG APP_ENV
ARG APP_PORT

WORKDIR $ROOT

ENV APP_ENV=$APP_ENV
ENV PORT=$APP_PORT

# Install and Update Libraries
RUN apt-get update && apt-get install -y autoconf gcc bash g++ make wget unzip libaio1 libaio-dev libxml2 libxml2-dev iputils-ping gettext-base nginx libcurl4-openssl-dev pkg-config libssl-dev supervisor vim nano gnupg2 telnet

# Dockerize Command
ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

# Install  Sockets and SOAP
RUN docker-php-ext-install soap sockets

# Install Mysql
RUN apt-get install -y libpq-dev libpng-dev libzip-dev \
    && docker-php-ext-install pdo pdo_mysql gd pcntl zip

# Install MongoDB
RUN pecl install mongodb-1.16.0; \
    echo "extension=mongodb.so" >> /usr/local/etc/php/conf.d/mongodb.ini;

# Install Heroku
RUN curl https://cli-assets.heroku.com/install.sh | sh
RUN apt-get update && apt-get install -y jq && apt-get clean

# Install Redis
RUN pecl install -o -f redis \
    && docker-php-ext-enable redis

# Copy Composer Instalation
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy config files to container
COPY ./ $ROOT
COPY .env.example ${ROOT}/.env
COPY /devops/supervisor/supervisor.conf /etc/supervisord.conf
COPY /devops/nginx/default.conf.template /etc/nginx/conf.d/default.conf.template
COPY /devops/nginx/nginx.conf /etc/nginx/nginx.conf
COPY /devops/php-fpm/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf
COPY /devops/php-fpm/error_reporting.ini /usr/local/etc/php/conf.d/error_reporting.ini

RUN if [ "$APP_ENV" = "local" ]; then \
        install-php-extensions xdebug \
        cp ${ROOT}/devops/php-fpm/php-local.ini /usr/local/etc/php/conf.d/app.ini; \
        cp ${ROOT}/devops/php-fpm/php-local.ini $PHP_INI_DIR/php.ini; \
        composer install --prefer-dist --optimize-autoloader; \
    else \
        cp ${ROOT}/devops/php-fpm/php.ini /usr/local/etc/php/conf.d/app.ini; \
        cp ${ROOT}/devops/php-fpm/php.ini $PHP_INI_DIR/php.ini; \
        composer install --prefer-dist --optimize-autoloader --no-dev; \
        # Download QGtunnel
        curl https://s3.amazonaws.com/quotaguard/qgtunnel-latest.tar.gz | tar xz; \
    fi

ADD /devops/scripts/entrypoint.sh /
RUN chmod +x /entrypoint.sh

# implement changes required to run NGINX as an unprivileged user
RUN sed -i '1d' /etc/nginx/nginx.conf

# Add unprivileged user to run the image
ARG UNAME=navebild
ARG UID=1001
ARG GID=1001
RUN addgroup --gid ${GID} ${UNAME}
RUN adduser --uid ${UID} --ingroup ${UNAME} --shell /bin/sh --disabled-login ${UNAME}
RUN chown ${UNAME}:${UNAME} -R $ROOT; \
    touch /run/nginx.pid /var/run/supervisord.pid && \
    chown -R ${UNAME}:${UNAME} /run/nginx.pid /var/run/supervisord.pid; \
    chown -R ${UNAME}:${UNAME} /var/log/nginx && \
    chown -R ${UNAME}:${UNAME} /var/lib/nginx && \
    chown -R ${UNAME}:${UNAME} /etc/nginx && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    usermod -aG ${UNAME} www-data
USER ${UNAME}

CMD ["/bin/bash", "-c", "/entrypoint.sh ${PORT}"]
