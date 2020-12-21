ARG ALPINE_BASE_IMAGE=alpine
ARG ALPINE_VERSION=3.12.3
ARG NGINX_BASE_IMAGE=nginxinc/nginx-unprivileged
ARG NGINX_VERSION=1.19.6-alpine

FROM ${ALPINE_BASE_IMAGE}:${ALPINE_VERSION} as build
ARG HUGO_VERSION=0.79.1
ENV HUGO_BINARY hugo_${HUGO_VERSION}_Linux-64bit.tar.gz
RUN apk add --update wget ca-certificates && \
    cd /tmp/ && \
    wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_BINARY} && \
    tar xzf ${HUGO_BINARY} && \
    rm -r ${HUGO_BINARY} && \
    mv hugo /usr/bin/hugo && \
    apk del wget ca-certificates && \
    rm /var/cache/apk/*
WORKDIR /site
COPY . .
RUN hugo -v -s /site -d /site/public

ARG NGINX_BASE_IMAGE
ARG NGINX_VERSION

FROM ${NGINX_BASE_IMAGE}:${NGINX_VERSION}
COPY config/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /site/public /usr/share/nginx/html
