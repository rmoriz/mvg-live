FROM ruby:4.0-alpine

COPY . /usr/src/mvg-live
WORKDIR /usr/src/mvg-live

RUN apk add --no-cache tzdata && \
    rm -rf .bundle Gemfile.lock && \
    gem build mvg-live.gemspec && \
    gem install --no-document mvg-live-*.gem && \
    rm -f mvg-live-*.gem

ENV TZ=Europe/Berlin

WORKDIR /
RUN rm -rf /usr/src/mvg-live
RUN adduser -Ss /bin/sh mvg
USER mvg

ENTRYPOINT ["mvg"]
