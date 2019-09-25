# frozen_string_literal: true

##
# Module used to wrap communication with Amazon Cognito
#
# Configuration of the client is done in config/initializers/cognito_client.rb and by ENV variables
#
module Cognito
  ##
  # Class responsible for initiating login process using
  # {InitiateAuth call}[https://docs.aws.amazon.com/cognito-user-identity-pools/latest/APIReference/API_InitiateAuth.html].
  #
  # Depending on user status, it returns user data directly or performs
  # {another call}[rdoc-ref:Cognito::GetUser.call] to get the data.
  #
  # ==== Usage
  #    user = Cognito::AuthUser.call(username: 'user@example.com', password: 'password')
  #
  class AuthUser < CognitoBaseService
    ##
    # Initializer method for the class. Used by class level method {call}[rdoc-ref:BaseService::call]
    #
    # ==== Attributes
    #
    # * +username+ - string, username submitted by the user
    # * +password+ - string, password submitted by the user
    #
    def initialize(username:, password:)
      @username = username
      @password = password
      @user = User.new
    end

    ##
    # Executing method for the class. Used by class level method {call}[rdoc-ref:BaseService::call]
    #
    # Returns an instance of the {User class}[rdoc-ref:User]
    # with attributes set with returned data from Amazon Cognito
    # if the login process is successful.
    #
    # Returns false if any exception occurs including InvalidParameterException,
    # which is raised if password or username doesn't match.
    #
    def call
      update_user(auth_user)
      user
    rescue AWS_ERROR::ServiceError => e
      log_error e
      false
    end

    private

    # Variables used internally by the service
    attr_reader :username, :password, :user

    # Performs the call to Cognito. Returns Cognito response.
    def auth_user
      log_action "Authenticating user: #{username}"
      auth_response = COGNITO_CLIENT.initiate_auth(
        client_id: ENV['AWS_COGNITO_CLIENT_ID'],
        auth_flow: 'USER_PASSWORD_AUTH',
        auth_parameters: { 'USERNAME' => username, 'PASSWORD' => password }
      )
      log_successful_call
      auth_response
    end

    # Based on user state (challenged or unchallenged) delegate to right update method
    def update_user(auth_response)
      if auth_response.authentication_result
        update_unchallenged_user(auth_response.authentication_result.access_token)
      else
        update_challenged_user(auth_response)
      end
    end

    # Update user based on Cognito call response.
    # Sets user's :aws_status to 'FORCE_NEW_PASSWORD' to force the password changing process.
    def update_challenged_user(auth_response)
      challenge_parameters = auth_response.challenge_parameters
      user.username = challenge_parameters['USER_ID_FOR_SRP']
      user.email = JSON.parse(challenge_parameters['userAttributes'])['email']
      user.aws_status = 'FORCE_NEW_PASSWORD'
      user.aws_session = auth_response.session
      user.hashed_password = Digest::MD5.hexdigest(password)
    end

    # Performs {next call}[rdoc-ref:Cognito::GetUser.call] to get user data of unchallenged user.
    # Passes username and access_token received from the previous call.
    def update_unchallenged_user(access_token)
      @user = Cognito::GetUser.call(access_token: access_token, username: username)
    end
  end
end
