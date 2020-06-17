# frozen_string_literal: true

##
# Module used to wrap communication with Amazon Cognito
module Cognito
  ##
  # Singleton Class used to request Cognito client.
  class Client
    include Singleton

    attr_reader :client

    ##
    # Initializer method for the service.
    #
    def initialize
      @client = Aws::CognitoIdentityProvider::Client.new(credentials: credentials)
    end

    ##
    # Method called when class does not implement the method
    # Then we try to call Cognito Client if respond to that method
    def method_missing(method, *args, &block)
      return client.send(method, *args, &block) if respond_to_missing?(method)

      super
    rescue Aws::CognitoIdentityProvider::Errors::ResourceNotFoundException,
           Aws::CognitoIdentityProvider::Errors::UnrecognizedClientException => e
      Rails.logger.info "Rescue From: #{e.class.name} - rotate credentials"
      # reload credentials
      @client = Aws::CognitoIdentityProvider::Client.new(credentials: credentials)
      # retry
      client.send(method, *args, &block)
    end

    ##
    # Method which check if Cognito Client respond to the missing method.
    def respond_to_missing?(method, include_private = false)
      client.respond_to?(method) || super
    end

    private

    # Loads Cognito Client Credentials.
    def credentials
      if secret_manager_credentials_provided?
        secret_manager_credentials
      else
        key_credentials
      end
    end

    # Check if COGNITO_SDK_SECRET is set
    def secret_manager_credentials_provided?
      ENV['COGNITO_SDK_SECRET']
    end

    # Loads Credentails from the ENV variables.
    def key_credentials
      Aws::Credentials.new(
        ENV.fetch('AWS_ACCESS_KEY_ID', 'AWS_ACCESS_KEY_ID'),
        ENV.fetch('AWS_SECRET_ACCESS_KEY', 'AWS_SECRET_ACCESS_KEY')
      )
    end

    # Loads Credentials from SecretManager
    def secret_manager_credentials
      sm_credentials = JSON.parse(
        secret_manager_client.get_secret_value(secret_id: ENV['COGNITO_SDK_SECRET']).secret_string
      )
      Aws::Credentials.new(
        sm_credentials['awsAccessKeyId'],
        sm_credentials['awsSecretAccessKey']
      )
    end

    # Loads SecretManager Client.
    def secret_manager_client
      Aws::SecretsManager::Client.new(
        region: ENV['AWS_REGION'],
        credentials: Aws::ECSCredentials.new({ ip_address: '169.254.170.2' })
      )
    end
  end
end
