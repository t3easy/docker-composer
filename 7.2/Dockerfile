FROM composer:1 AS composer

FROM php:7.2-alpine3.8

RUN apk --no-cache add --virtual .composer-rundeps git subversion openssh mercurial tini bash patch make zip unzip

RUN apk add --no-cache --virtual .build-deps zlib-dev libzip-dev \
 && docker-php-ext-configure zip --with-libzip \
 && docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) zip \
 && runDeps="$( \
    scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
    | tr ',' '\n' \
    | sort -u \
    | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )" \
 && apk add --virtual .composer-phpext-rundeps $runDeps \
 && apk del .build-deps

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp

ENV PATH "/tmp/vendor/bin:$PATH"
RUN mkdir -p -m 777 /tmp/cache

COPY --from=composer ["$PHP_INI_DIR/conf.d/*", "$PHP_INI_DIR/conf.d/"]
COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY --from=composer /docker-entrypoint.sh /docker-entrypoint.sh

WORKDIR /app

ENTRYPOINT ["/bin/sh", "/docker-entrypoint.sh"]

CMD ["composer"]
