FROM ruby:2.3-alpine

RUN apk --update add --virtual build_deps \
    build-base ruby-dev libc-dev linux-headers \
    openssl-dev postgresql-dev libxml2-dev libxslt-dev && \
    bundle config build.nokogiri --use-system-libraries && \
    gem install mvg-live && \
    apk del build_deps

RUN adduser -Ss /bin/sh mvg
USER mvg

ENTRYPOINT ["mvg"]
