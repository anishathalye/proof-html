FROM alpine:3.19 AS base

RUN apk --no-cache add openjdk11

FROM base AS build-vnu

RUN apk add git python3

RUN git clone -n https://github.com/validator/validator.git \
    && cd validator \
    && git checkout 3b2fd66eec435b5d5e42698e70679e769ed33136 \
    && JAVA_HOME=/usr/lib/jvm/java-11-openjdk python checker.py update-shallow dldeps build jar

FROM base

RUN apk --no-cache add build-base linux-headers ruby-dev
RUN apk --no-cache add curl
RUN gem install html-proofer -v 5.0.9

RUN apk --no-cache add bash

COPY --from=build-vnu /validator/build/dist/vnu.jar /bin/vnu.jar

COPY entrypoint.sh proof-html.rb /

ENTRYPOINT ["/entrypoint.sh"]
