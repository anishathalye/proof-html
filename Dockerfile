FROM alpine:3.18 as base

RUN apk --no-cache add openjdk8

FROM base as build-vnu

RUN apk add git python3

RUN git clone -n https://github.com/validator/validator.git \
    && cd validator \
    && git checkout ed62b92a2dd36b02711333f43f459f23218a2ac1 \
    && JAVA_HOME=/usr/lib/jvm/java-8-openjdk python checker.py update-shallow dldeps build jar

FROM base

RUN apk --no-cache add build-base linux-headers ruby-dev
RUN apk --no-cache add curl
RUN gem install html-proofer -v 5.0.8

RUN apk --no-cache add bash

COPY --from=build-vnu /validator/build/dist/vnu.jar /bin/vnu.jar

COPY entrypoint.sh proof-html.rb /

ENTRYPOINT ["/entrypoint.sh"]
