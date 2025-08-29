FROM node:18.20.4-alpine3.20 AS build-stage

RUN apk add git
RUN set -eux \
    && mkdir -p /app \
    && mkdir -p /api

COPY frontend/ /app
COPY entrypoint.sh /api/entrypoint.sh

WORKDIR /app
RUN rm -rf src/components/Stacks-Editor || true
RUN git clone https://github.com/BaldissaraMatheus/Stacks-Editor src/components/Stacks-Editor
RUN cd src/components/Stacks-Editor && npm ci --no-audit
RUN set -eux && npm ci --no-audit --omit=dev

COPY backend/ /api/

WORKDIR /api
RUN set -eux && npm ci --no-audit

FROM alpine:3.20 AS final
USER root
RUN set -eux && apk add --no-cache nodejs npm
RUN mkdir /stylesheets

COPY --from=build-stage /app /app
COPY --from=build-stage /api/ /api/

WORKDIR /api
EXPOSE 8080

ENTRYPOINT sh entrypoint.sh
