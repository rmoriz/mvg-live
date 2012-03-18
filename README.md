# MVG-LIVE

A ruby client and CLI for mvg-live.de the real-time interface for Munich's public transportation service.

[![Build Status](https://secure.travis-ci.org/rmoriz/mvg-live.png?branch=master)](http://travis-ci.org/rmoriz/mvg-live)


## Installation

    gem install mvg-live


## CLI

This gem provides two scripts:

### mvg

Returns a human readable listing of the next depatures

    $ mvg Hauptbahnhof
    $ mvg Marienplatz
    $ mvg Moosach Bf.

### mvg_json

Returns JSON

    $ mvg_json Hauptbahnhof
    $ mvg_json Marienplatz
    $ mvg_json Moosach Bf.

## Ruby

    require 'mvg/live'
    result = MVG::Live.fetch 'Sendlinger Tor'

    => [{:line=>"17", :destination=>"Amalienburgstraße", :minutes=>3}, {:line=>"U6", :destination=>"Garching-Forschungs.", :minutes=>5} ...


## Minitest-Specs

see "specs/"-directory


## Disclaimer

This project is not related, acknowledged, sponsored... by MVG or SWM.
Use on your own risk.

## License

see LICENSE file (BSD)

## Created by

Roland Moriz