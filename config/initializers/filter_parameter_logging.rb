# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += %i[
  email
  username
  aws_status
  aws_session
  sub
  hashed_password
  login_ip
  password
  confirmation_code
  authenticity_token
]
