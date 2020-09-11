# frozen_string_literal: true

##
# Module used to wrap communication with Amazon Cognito
#
# Configuration of the client is done in services/cognito/client.rb and by ENV variables
#
module AuthenticationStrategies
  ##
  # Class responsible for validating user email and authenticating user.
  #
  class Remote < Devise::Strategies::Authenticatable
    # For an example check:
    # https://github.com/plataformatec/devise/blob/master/lib/devise/strategies/database_authenticatable.rb
    # Method called by warden to authenticate a resource.
    def authenticate!
      # authentication_hash doesn't include the password
      auth_params = authentication_hash
      auth_params[:password] = password

      # add request IP for security reasons
      auth_params[:login_ip] = request.remote_ip

      # mapping.to is a wrapper over the resource model
      resource = mapping.to.new
      return fail! unless resource

      authenticate_user(resource, auth_params)
    end

    private

    # Returns a string, eg. 'user@example.com'
    def username
      authentication_hash[:username]
    end

    def authenticate_user(resource, auth_params)
      # remote_authentication method is defined in Devise::Models::RemoteAuthenticatable
      #
      # validate is a method defined in Devise::Strategies::Authenticatable. It takes
      # a block which must return a boolean value.
      #
      # If the block returns true the resource will be logged in
      # If the block returns false the authentication will fail!
      #
      # resource = resource.authentication(auth_params)
      if validate(resource) { resource = resource.authentication(auth_params) }
        success!(resource)
      else
        fail!(:invalid)
      end
    end
  end
end
