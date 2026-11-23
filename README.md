# MVG-LIVE

A ruby client and CLI for Munich's public transport (MVG) real-time departure monitor.

[![CI](https://github.com/rmoriz/mvg-live/actions/workflows/ci.yml/badge.svg)](https://github.com/rmoriz/mvg-live/actions/workflows/ci.yml)
[![Downloads](https://img.shields.io/gem/dtv/mvg-live.svg?style=flat-square)](https://rubygems.org/gems/mvg-live)
[![Tags](https://img.shields.io/github/tag/rmoriz/mvg-live.svg?style=flat-square)](https://github.com/rmoriz/mvg-live/tags)
[![Issues](https://img.shields.io/github/issues/rmoriz/mvg-live.svg?style=flat-square)](https://github.com/rmoriz/mvg-live/issues)
[![License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](http://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/gem/v/mvg-live.svg?style=flat-square)](https://rubygems.org/gems/mvg-live)

## Installation


### Docker

```shell
docker pull rmoriz/mvg-live:latest
docker run -it --rm rmoriz/mvg-live Marienplatz
```
### Rubygem

```shell
gem install mvg-live
```

Please use Ruby 3.2.x or greater.


## Ruby

    require 'mvg/live'

    result = MVG::Live.fetch 'Sendlinger Tor', transports: [:u, :tram]
    => [{:line=>"U3", :destination=>"Fürstenried West", :minutes=>1}, ...]

    result = MVG::Live.fetch 'Sendlinger Tor', transports: [:tram]
    => [{:line=>"17", :destination=>"Schwanseestraße", :minutes=>0}, ...]

Every entry is a hash with `:line`, `:destination` and `:minutes`.

## CLI (command line interface)

This gem provides two scripts:

### mvg

Returns a human readable listing of the next departures

    $ mvg Hauptbahnhof
    $ mvg Marienplatz
    $ mvg Moosach Bf.

example output:

    ================================================
    Hauptbahnhof: U, Bus, Tram, S
    ======================================[ 09:03 ]=
    19  | Pasing                        |  0 Minuten
    16  | Romanplatz                    |  1 Minuten
    U2  | Feldmoching                   |  1 Minuten
    U1  | Mangfallplatz                 |  1 Minuten
    S8  | Herrsching                    |  2 Minuten
    ...

displays alternates/suggestions in case of unclear/invalid station name:

    $ mvg Tor
    ================================================
       /!\ Station unknown!  Did you mean...? /!\   
    ================================================
     - Sendlinger Tor
     - Schwabinger Tor


### mvg_json

Returns JSON

    $ mvg_json Hauptbahnhof
    $ mvg_json Marienplatz
    $ mvg_json Moosach Bf.

### User Preferences

You can specify a default station or a default transports list (e.g. only specific transport systems) in a JSON file. This only affects the CLI version!
The first available file will be loaded:

1. file specified in the environment variable: `MVG_FILE`
2. an existing .mvg file in the current directory (`PWD`)
3. an existing .mvg file in the home directory of the current user (`HOME`)

Example .mvg file:

     {"default_transports":["u"],"default_station":"Hauptbahnhof"}

This limits the transports to U-Bahn and uses "Hauptbahnhof" as default station:

    $ mvg
    =[                         /Users/rmoriz/.mvg ]=
    Hauptbahnhof: U
    ======================================[ 13:34 ]=
    U1  | Mangfallplatz                 |  0 Minuten
    U2  | Feldmoching                   |  0 Minuten
    U4  | Arabellapark                  |  3 Minuten
    ...

You can overwrite the station as mentioned above but the transport limitation is currently *global*!

    $ mvg Ostbahnhof
    =[                         /Users/rmoriz/.mvg ]=
    Ostbahnhof: U
    ======================================[ 13:37 ]=
    U5  | Neuperlach Süd                |  2 Minuten
    U5  | Laimer Platz                  |  8 Minuten
    ...

The default transports list (= all available) is:

Ruby:

    [ :u, :bus, :tram, :s ]

JSON:

    ["u", "bus", "tram", "s"]


## Data source

The client talks to the (undocumented) JSON API that powers [mvg.de](https://www.mvg.de):

- `GET https://www.mvg.de/api/bgw-pt/v3/locations?query=<station>` to resolve a station name
- `GET https://www.mvg.de/api/bgw-pt/v3/departures?globalId=<id>` for the departures

Requests are sent with the public API key used by the MVG web app. It can be
overridden by passing `api_key:` to `MVG::Live.new`, and the base URL by
passing `base_url:`.

## Upgrading from 2.x

- Nokogiri/HTML scraping was replaced by the JSON API, the old
  `www.mvg-live.de` endpoint is gone.
- Faraday 2 and ActiveModel 8 are required, Ruby 3.2+.
- `schema:`, `host:` and `path:` options were replaced by `base_url:`.
- The default encoding is UTF-8 (`encoding:` is still available).


## Minitest-Specs

see "spec/"-directory. The HTTP fixtures are recorded from the live API and
replayed with VCR, so the suite runs offline. Record new episodes with:

    rm -rf spec/fixtures/vcr_cassettes && bundle exec rake test


## Disclaimer

This project is not related, acknowledged, sponsored... by MVG or SWM.
Use at your own risk.

## License

see LICENSE file (MIT)

## Copyright

Copyright
---------

Copyright © 2016 [Roland Moriz](https://roland.io), [Moriz GmbH](https://moriz.de/)

[![LinkedIn](http://www.linkedin.com/img/webpromo/btn_viewmy_160x25.png)](https://www.linkedin.com/in/rmoriz)
[![Twitter](http://i.imgur.com/1kYFHlu.png)](https://twitter.com/rmoriz)
