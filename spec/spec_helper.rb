# frozen_string_literal: true

# Checks if no external calls are being performed during tests
require 'webmock/rspec'
# Checks code coverage
require 'simplecov'
# manipulate with cookies
require 'show_me_the_cookies'

SimpleCov.start 'rails' do
  # minimum coverage percentage expected
  minimum_coverage 84
  # ignore next folders and files
  add_filter %w[
    app/models/application_record.rb
    lib/
    config/
  ]
end
