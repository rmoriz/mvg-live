#!/usr/bin/env ruby
# frozen_string_literal: true

# Rebases all recorded departure timestamps onto the fixed time used by the
# specs (BASE_TIME in spec/mvg_live_spec.rb), so minute assertions stay
# deterministic. Run after recording and before the green test run:
#
#   rm -rf spec/fixtures/vcr_cassettes
#   bundle exec rake test
#   ruby script/rewrite_cassettes.rb
#   bundle exec rake test
#
# The script is idempotent.

require 'json'

BASE_MS = Time.utc(2030, 1, 1, 12, 0, 0).to_i * 1000
MINUTE = 60_000

Dir['spec/fixtures/vcr_cassettes/**/*.json'].each do |path|
  document = JSON.parse(File.read(path))
  changed = false

  Array(document['http_interactions']).each do |interaction|
    next unless interaction['request']['uri'].include?('departures')

    body = JSON.parse(interaction['response']['body']['string'])
    next unless body.is_a?(Array)

    stamps = body.map { |entry| entry['realtimeDepartureTime'] || entry['plannedDepartureTime'] }.compact
    next if stamps.empty?

    first = stamps.min

    body.each do |entry|
      stamp = entry['realtimeDepartureTime'] || entry['plannedDepartureTime']
      offset = stamp ? ((stamp - first) / MINUTE.to_f).round * MINUTE : 0
      entry['realtimeDepartureTime'] = BASE_MS + offset
      entry['plannedDepartureTime'] = BASE_MS + offset
    end

    interaction['response']['body']['string'] = JSON.generate(body)
    changed = true
  end

  File.write(path, JSON.pretty_generate(document)) if changed
end
