# MVG-LIVE

A ruby client and CLI for mvg-live.de the real-time interface for Munich's public transportation service.

[![Build Status](https://secure.travis-ci.org/rmoriz/mvg-live.png?branch=master)](http://travis-ci.org/rmoriz/mvg-live)


[![Flattr](https://api.flattr.com/button/flattr-badge-large.png)](https://flattr.com/submit/auto?user_id=flattr&url=https://github.com/rmoriz/mvg-live&title=mvg-live%20rubygem&description=mvg-live%20rubygem&language=de_DE&tags=fahrplan,mvg,swm,ruby,code,u-bahn,s-bahn,tram,muenchen&category=software)
  
  
## Installation

    gem install mvg-live


## Ruby

    require 'mvg/live'
    result = MVG::Live.fetch 'Sendlinger Tor'

    => [{:line=>"17", :destination=>"Amalienburgstraße", :minutes=>3}, {:line=>"U6", :destination=>"Garching-Forschungs.", :minutes=>5} ...

## CLI (command line interface)

This gem provides two scripts:

### mvg

Returns a human readable listing of the next depatures

    $ mvg Hauptbahnhof
    $ mvg Marienplatz
    $ mvg Moosach Bf.

example output:


<img src="http://i.imgur.com/LLGYs.jpg">
<img src="http://i.imgur.com/rO6Fz.jpg">

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


displays alternates/suggestions in case of unclear/invalid station name:

    $ mvg Tor
    ================================================
       /!\ Station unknown!  Did you mean...? /!\   
    ================================================
     - Am Münchner Tor
     - Sendlinger Tor


### mvg_json

Returns JSON

    $ mvg_json Hauptbahnhof
    $ mvg_json Marienplatz
    $ mvg_json Moosach Bf.

<img src="http://i.imgur.com/7pxh9.jpg">


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
    U4  | Theresienwiese                |  4 Minuten
    ...

You can overwrite the station as mentioned above but the transport limitation is currently *global*!

    $ mvg Ostbahnhof
    =[                         /Users/rmoriz/.mvg ]=
    Ostbahnhof: U
    ======================================[ 13:37 ]=
    U5  | Neuperlach Süd                |  2 Minuten
    U5  | Laimer Platz                  |  8 Minuten
    U5  | Neuperlach Süd                | 12 Minuten
    ...

The default transports list (= all available) is:

Ruby:

    [ :u, :bus, :tram, :s ]

JSON:

    ["u", "bus", "tram", "s"]


## Minitest-Specs

see "specs/"-directory


## Disclaimer

This project is not related, acknowledged, sponsored... by MVG or SWM.
Use on your own risk.

## License

see LICENSE file (BSD)

## Created by

Roland Moriz