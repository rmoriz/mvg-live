FROM ruby:2.3-alpine

COPY . /usr/src/mvg-live
WORKDIR /usr/src/mvg-live

RUN rm -rf .bundle
RUN rm -rf Gemfile.lock

RUN apk --update add --virtual build_deps \
    build-base git ruby-dev \
    libxml2 libxml2-dev libxslt libxslt-dev && \
    gem install nokogiri && \
    bundle install --without development && \
    rake install:local && \
    apk del build_deps git


WORKDIR /
RUN rm -rf /usr/src/mvg-live
RUN adduser -Ss /bin/sh mvg
USER mvg

ENTRYPOINT ["mvg"]
