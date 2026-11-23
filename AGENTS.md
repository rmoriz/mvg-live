# AGENTS.md

Guidance for coding agents working in this repository.

## What this is

`mvg-live` is a Ruby gem plus two CLI scripts (`bin/mvg`, `bin/mvg_json`) that
show real-time departures for Munich's public transport. Data comes from the
undocumented JSON API that powers mvg.de. It is a hobby project, unrelated to
MVG/SWM.

## Setup

```sh
bundle install
bundle exec rake test
```

Requirements: Ruby >= 3.3, Bundler 4. Keep `Gemfile.lock` committed, it is part
of the reproducible build.

## Commands

| Task | Command |
|---|---|
| Full suite | `bundle exec rake test` (or plain `rake`) |
| Single test | `bundle exec ruby -Ilib -Ispec spec/mvg_live_spec.rb -n "/station lookup/"` |
| Live CLI check | `bundle exec ruby -Ilib bin/mvg Marienplatz` |
| Syntax check | `for f in $(git ls-files 'lib/*.rb' 'spec/*.rb'); do ruby -cw "$f"; done` |
| Security audit | `bundle audit check` |
| Gem build | `gem build mvg-live.gemspec` |
| Docker image | `docker build -t mvg-live:test . && docker run --rm mvg-live:test Marienplatz` |

There is no RuboCop config; match the existing style (2-space indent, `%i[]`
for symbol arrays, short single-purpose methods, `frozen_string_literal` only
where already present).

## Layout

- `lib/mvg/live.rb` – `MVG::Live`, option handling, inline validations
  (`MVG::Live::Errors`), UTF-8 helper.
- `lib/mvg/live/http.rb` – Net::HTTP client, station resolution, departures request.
- `lib/mvg/live/parser.rb` – turns the JSON payload into `{line:, destination:, minutes:}` hashes.
- `lib/mvg/live/cli.rb` – display/JSON rendering, `.mvg` user defaults, station name hacks.
- `bin/` – the two entry points; keep them thin.
- `spec/` – Minitest specs; `spec/spec_helper.rb` wires VCR.

Request flow: `fetch` → `resolve_station` (GET `locations`) → GET `departures`
→ `parse`. An unmatched station sets `station_unknown` and
`station_alternates` instead of raising.

## API notes

- Base URL `https://www.mvg.de/api/bgw-pt/v3`, header
  `x-mvg-authority-check-api-key: <API_KEY>` (public key from the MVG web app).
- Transport filter is a comma separated `transportTypes` value of
  `UBAHN,BUS,TRAM,SBAHN`; the API caps `limit` at 30.
- Station matching is exact (case-insensitive, trailing additions in
  parentheses stripped, `aliases` honoured). Suggestions are only a fallback.
- Minutes are derived from `realtimeDepartureTime`/`plannedDepartureTime` and
  clamped at 0; cancelled entries are skipped. Results are cut at
  `DEFAULT_MAX_MINUTES` (60) unless `all: true` is passed.
- CLI flags are parsed by `MVG::Live::CLI.parse_argv` (`--all`, `--help`); the
  usage text lives in `MVG::Live::CLI.usage`.

## Tests and fixtures

HTTP fixtures live in `spec/fixtures/vcr_cassettes` and are replayed offline
through VCR's WebMock hook (WebMock blocks unstubbed connections). Never let a
spec hit the network implicitly.

To refresh fixtures:

```sh
rm -rf spec/fixtures/vcr_cassettes
bundle exec rake test          # records, some assertions may fail
ruby script/rewrite_cassettes.rb
bundle exec rake test          # must be green and offline
```

`script/rewrite_cassettes.rb` rebases departure timestamps onto the fixed
`BASE_TIME` used by the specs, which keeps minute assertions deterministic.
The script is idempotent — never hand-edit cassette timestamps.

Parser specs use `stub_response` to inject a payload, so they need no cassette.

## Conventions

- The gem has **no runtime dependencies** (stdlib `net/http` + `json` only).
  Think twice before adding one; dev dependencies are fine.
- Public API compatibility matters: `MVG::Live.fetch(station, transports:)`,
  `result_display`, `result_sorted`, `station_unknown`, `station_alternates`,
  `to_display`, `to_json` are all used by the CLIs and downstream users.
- UTF-8 everywhere; never reintroduce the old ISO-8859-1 handling.
- Update `CHANGELOG.md` for user-visible changes. Bump
  `lib/mvg/live/version.rb` for releases.
- Commit messages explain the *why*. Do **not** add
  `Co-Authored-By: Claude`.
- Push commits and release notes to `origin/main`; CI must stay green
  (`.github/workflows/ci.yml`, Ruby 3.3/3.4/4.0/head).
- `spec/` and the Docker image must keep working without network access at
  build time (Docker only needs rubygems.org during `gem install`).
