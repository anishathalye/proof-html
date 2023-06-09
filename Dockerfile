FROM alpine:3.18

RUN apk --no-cache add build-base ruby-dev
RUN apk --no-cache add curl
RUN gem install html-proofer -v 5.0.7

RUN apk --no-cache add python3 py3-pip
RUN apk --no-cache add openjdk8
RUN pip install 'html5validator==0.4.2'

RUN apk --no-cache add bash

COPY entrypoint.sh proof-html.rb /

ENTRYPOINT ["/entrypoint.sh"]
