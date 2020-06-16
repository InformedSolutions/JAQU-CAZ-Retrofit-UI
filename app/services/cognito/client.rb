# frozen_string_literal: true

module Cognito
  class Client
    include Singleton

    attr_reader :client

    def initialize
      @client = Aws::CognitoIdentityProvider::Client.new(credentials: credentials)
    end

    def method_missing(method, *args, &block)
      return client.send(method, *args, &block) if client.respond_to?(method)

      super
    rescue Aws::CognitoIdentityProvider::Errors::ResourceNotFoundException
      Rails.logger.info 'Error: get new credentials and retry action'
      # reload credentials
      @client = Aws::CognitoIdentityProvider::Client.new(credentials: credentials)
      # retry
      client.send(method, *args, &block)
    end

    def respond_to_missing?(method, include_private = false)
      client.respond_to?(method) || super
    end

    private

    def credentials
      if secret_manager_credentials_provided?
        secret_manager_credentials
      else
        key_credentials
      end
    end

    def secret_manager_credentials_provided?
      ENV['COGNITO_SDK_SECRET']
    end

    def key_credentials
      Rails.logger.info 'Getting credentials from ENV'
      Aws::Credentials.new(
        ENV.fetch('AWS_ACCESS_KEY_ID', 'AWS_ACCESS_KEY_ID'),
        ENV.fetch('AWS_SECRET_ACCESS_KEY', 'AWS_SECRET_ACCESS_KEY')
      )
    end

    def secret_manager_credentials
      Rails.logger.info 'Getting credentials from SecretsManager'
      secret_manager_client
        .get_secret_value(secret_id: ENV['COGNITO_SDK_SECRET'])
    end

    def secret_manager_client
      Rails.logger.info 'Loading SecretsManager cCanlient'
      Aws::SecretsManager::Client.new(
        credentials: Aws::ECSCredentials.new({ ip_address: '169.254.170.2' }),
        region: ENV['AWS_REGION']
      )
    end
  end
end
