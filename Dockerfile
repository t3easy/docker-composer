# syntax=docker/dockerfile:1
ARG ALPINE_VERSION
ARG COMPOSER_VERSION=latest
ARG PHP_VERSION=cli

FROM composer:${COMPOSER_VERSION} as composer

FROM php:${PHP_VERSION}-alpine${ALPINE_VERSION}

LABEL org.opencontainers.image.source="https://github.com/t3easy/docker-composer"

RUN set -eux; \
  apk add --no-cache --virtual .composer-rundeps \
    bash \
    coreutils \
    git \
    make \
    mercurial \
    openssh-client \
    patch \
    subversion \
    tini \
    unzip \
    zip

RUN set -eux; \
  apk add --no-cache --virtual .build-deps \
    libzip-dev \
    zlib-dev \
  ; \
  case $PHP_VERSION in \
    7.2.*) \
      docker-php-ext-configure zip --with-libzip;; \
  esac; \
  docker-php-ext-install -j "$(nproc)" \
    zip \
  ; \
  runDeps="$( \
    scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
      | tr ',' '\n' \
      | sort -u \
      | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
  apk add --no-cache --virtual .composer-phpext-rundeps $runDeps; \
  apk del .build-deps

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp

ENV PATH "/app/vendor/bin:/tmp/vendor/bin:$PATH"

COPY --from=composer $PHP_INI_DIR/php-cli.ini $PHP_INI_DIR/php-cli.ini
COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY --from=composer /docker-entrypoint.sh /docker-entrypoint.sh

RUN set -eux; \
  composer --ansi --version --no-interaction; \
  find /tmp -type d -exec chmod -v 1777 {} +

WORKDIR /app

ENTRYPOINT ["/bin/sh", "/docker-entrypoint.sh"]

CMD ["composer"]
