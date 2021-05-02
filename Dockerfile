FROM ruby:3.0-alpine

RUN apk --no-cache add \
    build-base \
    curl \
    ruby-dev \
  && gem install html-proofer

COPY entrypoint.sh proof-html.rb /

ENTRYPOINT ["/entrypoint.sh"]
