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

example output:

    ================================================
    Hauptbahnhof: U, Bus, Tram, S
    ======================================[ 09:03 ]=
    19  | Pasing                        |  0 Minuten
    16  | Romanplatz                    |  1 Minuten
    U2  | Feldmoching                   |  1 Minuten
    U1  | Mangfallplatz                 |  1 Minuten
    S8  | Herrsching                    |  2 Minuten
    U2  | Messestadt Ost                |  3 Minuten
    17  | Schwanseestraße               |  3 Minuten
    S7  | Aying                         |  4 Minuten
    U4  | Arabellapark                  |  4 Minuten
    U4  | Theresienwiese                |  5 Minuten
    S6  | Ostbahnhof                    |  5 Minuten
    U2  | Messestadt Ost                |  6 Minuten
    S2  | Petershausen                  |  6 Minuten
    20  | Moosach Bf.                   |  6 Minuten
    U1  | Olympia - Einkaufszentrum     |  6 Minuten
    19  | Pasing                        |  8 Minuten
    U5  | Neuperlach Süd                |  8 Minuten
    16  | Romanplatz                    |  8 Minuten
    U5  | Laimer Platz                  |  9 Minuten
    U1  | Mangfallplatz                 | 11 Minuten

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