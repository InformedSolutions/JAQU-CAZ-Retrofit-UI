# frozen_string_literal: true

# Checks if no external calls are being performed during tests
require 'webmock/rspec'
# Checks code coverage
require 'simplecov'
# Manipulate with cookies
require 'show_me_the_cookies'
# Ruby documentation tool
require 'yard'

# Run scanner to check which files need to be documented
warn('Code documentation coverage:')
YARD::CLI::Stats.new.run('--list-undoc', '--private', '--compact', '--no-save', '-q')

SimpleCov.start 'rails' do
  # minimum coverage percentage expected
  minimum_coverage 100
  # ignore next folders and files
  add_filter %w[
    app/models/application_record.rb
    app/services/cognito/client.rb
    lib/
    config/
  ]
end
