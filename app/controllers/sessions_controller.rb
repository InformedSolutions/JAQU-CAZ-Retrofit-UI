# frozen_string_literal: true

##
# Controller class for overwriting Devise methods.
#
class SessionsController < Devise::SessionsController
  ##
  # Called on user login.
  #
  # ==== Path
  #
  #    :POST /users/sign_in
  #
  # ==== Params
  # * +username+ - string, user email address
  # * +password+ - string, password submitted by the user
  #
  def create
    if credentials_valid?
      super
    else
      redirect_to new_user_session_path
    end
  end

  private

  ##
  # Validate user data.
  # 1. Check if both inputs are filled.
  # 2. Check if email is in correct format.
  #
  # Returns a boolean.
  def credentials_valid?
    params[:user] && both_fields_filled? && email_format_valid?
  end

  ##
  # Checks if both email and password are filled
  #
  # Returns a boolean.
  def both_fields_filled?
    return true if !params[:user][:username].empty? && !params[:user][:username].empty?

    flash['errors'] = {
      email: I18n.t('email.errors.required'),
      password: I18n.t('password.errors.required')
    }

    false
  end

  ##
  # Checks if email is in correct format
  #
  # Returns a boolean.
  def email_format_valid?
    return true if Devise.email_regexp =~ params[:user][:username]

    flash['errors'] = {
      email: I18n.t('email.errors.invalid_format'),
      password: I18n.t('password.errors.required')
    }

    false
  end
end
