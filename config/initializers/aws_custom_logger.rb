# frozen_string_literal: true

# :nocov:
module Aws
  module Plugins
    class Logging < Seahorse::Client::Plugin
      class Handler < Seahorse::Client::Handler
        private

        # Do not log AWS::SES response by the reason that we should not see user email
        # Do not log Aws::CognitoIdentityProvider::Client response
        # by the reason that we should not see password reset confirmation_code
        # TO DO: Modify response to log it without confirmation_code
        def log(config, response)
          return if %w[ses cognito-idp].include?(config.sigv4_signer.service)

          config.logger.send(config.log_level, format(config, response))
        end
      end
    end
  end
end
# :nocov:
