# Changelog

## 3.0.0 (2026-11-23)

Complete modernization after the shutdown of the old
`www.mvg-live.de/ims/dfiStaticAuswahl.svc` endpoint.

- Replace HTML scraping with the JSON API of mvg.de
  (`/api/bgw-pt/v3/locations` and `/api/bgw-pt/v3/departures`).
- Drop Nokogiri and multi_json, the response is parsed as JSON.
- Drop all runtime dependencies: plain Net::HTTP and JSON instead of
  Faraday, an internal `MVG::Live::Errors` instead of ActiveModel.
- Require Ruby >= 3.3; replace the dead Travis CI setup with GitHub Actions.
- Replace the `schema:`/`host:`/`path:` options with `base_url:`.
- Fix `MVG::Live.new` crashing when user defaults are loaded without a station.
- Skip cancelled departures and clamp departures in the past to 0 minutes.
- Limit departures to the next 60 minutes by default; `--all` shows the full
  API response.
- Read the server time from the local clock, the new API does not send one.
- Refresh the Docker image (Ruby 4.0 Alpine, no build dependencies).

## 2.3.0

- Downgrade mocha, update dependencies.

## 2.2.0

- Update dependencies, cleanup.

## 2.1.0

- Prepare release.
