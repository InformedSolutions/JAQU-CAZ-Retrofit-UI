module Cognito
  class Client
    def initialize
      Aws::CognitoIdentityProvider::Client.new(credentials)
    end

    private

    def credentials
      if key_credentials_provided?
        key_credentials
      else
        secret_manager_credentials
      end
    end

    def key_credentials_provided?
      ENV['AWS_SECRET_KEY'] && ENV['AWS_SECRET_ACCESS_KEY']
    end

    def key_credentials
      Aws::Credentials.new(
        ENV.fetch('AWS_SECRET_KEY', 'AWS_SECRET_KEY'),
        ENV.fetch('AWS_SECRET_ACCESS_KEY', 'AWS_SECRET_ACCESS_KEY')
      )
    end

    def secret_manager_credentials
      secret_manager_client.get_secret_value(secret_id: secret_name)
    end

    def secret_manager_client
      Aws::SecretsManager::Client.new(
        credentials: Aws::ECSCredentials.new({ ip_address: '169.254.170.2' }),
        region: ENV['AWS_REGION']
      )
    end

    def secret_name
      ENV['COGNITO_SDK_SECRET']
    end
  end
end
