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
    if credentials_invalid?
      redirect_to new_user_session_path
    else
      super
    end
  end

  private

  ##
  # Validate user data.
  # 1. Check if both inputs are filled.
  # 2. Check if email is in correct format.
  #
  # Returns a boolean.
  def credentials_invalid?
    both_fields_unfilled? || email_format_invalid?
  end

  ##
  # Checks if both email and password are filled
  #
  # Returns a boolean.
  def both_fields_unfilled?
    return if user_params['username'].present? && user_params['password'].present?

    flash[:errors] = {
      email: I18n.t('email.errors.required'),
      password: I18n.t('password.errors.required')
    }
  end

  ##
  # Checks if email is in correct format
  #
  # Returns a boolean.
  def email_format_invalid?
    error_message = EmailValidator.call(email: user_params['username'])
    return if error_message.nil?

    flash[:errors] = {
      email: error_message,
      password: I18n.t('password.errors.required')
    }
  end

  # Returns the list of permitted params
  def user_params
    params.require(:user).permit(:username, :password)
  end
end
