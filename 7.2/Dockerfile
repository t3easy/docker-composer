FROM php:7.2-alpine

RUN apk add --no-cache --virtual .composer-rundeps git subversion openssh-client mercurial tini bash patch make zip unzip coreutils \
 && apk add --no-cache --virtual .build-deps zlib-dev libzip-dev \
 && docker-php-ext-configure zip --with-libzip \
 && docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) zip opcache \
 && runDeps="$( \
    scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
      | tr ',' '\n' \
      | sort -u \
      | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )" \
 && apk add --no-cache --virtual .composer-phpext-rundeps $runDeps \
 && apk del .build-deps

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp

ENV PATH "/tmp/vendor/bin:$PATH"

COPY --from=composer:1 ["$PHP_INI_DIR/php-cli.ini", "$PHP_INI_DIR/php-cli.ini"]
COPY --from=composer:1 /usr/bin/composer /usr/bin/composer
COPY --from=composer:1 /docker-entrypoint.sh /docker-entrypoint.sh

RUN composer --ansi --version --no-interaction \
 && find /tmp -type d -exec chmod -v 1777 {} +

WORKDIR /app

ENTRYPOINT ["/bin/sh", "/docker-entrypoint.sh"]

CMD ["composer"]
