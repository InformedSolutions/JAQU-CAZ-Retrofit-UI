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
      c = secret_manager_client.get_secret_value(secret_id: ENV['COGNITO_SDK_SECRET'])
      Rails.logger.info 'Credentials from SecretsManager loaded.'
      c
    end

    def secret_manager_client
      Rails.logger.info 'Loading SecretsManager Client'
      Aws::SecretsManager::Client.new(
        region: ENV['AWS_REGION'],
        credentials: ecs_credentials
      )
    end

    def ecs_credentials
      Rails.logger.info 'Loading SecretsManager Client'
      response = Aws::ECSCredentials.new({ ip_address: '169.254.170.2' })
      Rails.logger.info 'ECSCredentials response:'
      log_ecs_response(response)
      response
    end

    def log_ecs_response(response)
      Rails.logger.info "AccessKeyId: #{response['AccessKeyId'].last(4)}"
      Rails.logger.info "Expiration: #{response['Expiration']}"
      Rails.logger.info "SecretAccessKey: #{response['SecretAccessKey'].last(4)}"
      Rails.logger.info "Token: #{response['Token'].last(4)}"
    end
  end
end
