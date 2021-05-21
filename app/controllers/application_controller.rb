# frozen_string_literal: true

##
# Base controller class. Contains some basic endpoints.
#
class ApplicationController < ActionController::Base
  # protects applications against CSRF
  protect_from_forgery prepend: true
  # rescues from upload validation or if upload to AWS S3 failed
  rescue_from CsvUploadFailureException, with: :handle_exception
  # rescues from API and security errors
  rescue_from InvalidHostException, with: :render_service_unavailable

  # check if host headers are valid
  before_action :validate_host_headers!,
                except: %i[health build_id],
                if: -> { Rails.env.production? && Rails.configuration.x.host.present? }

  ##
  # Health endpoint
  #
  # Used as a health check - returns 200 HTTP status
  #
  # ==== Path
  #
  #    GET /health.json
  #
  def health
    render json: 'OK', status: :ok
  end

  ##
  # Build ID endpoint
  #
  # Used by CI to determine if the new version is already deployed.
  # +BUILD_ID+ environment variables is used to set it's value. If nothing is set, returns 'undefined
  #
  # ==== Path
  #
  #    GET /build_id.json
  #
  def build_id
    render json: ENV.fetch('BUILD_ID', 'undefined'), status: :ok
  end

  private

  # Adds checking IP to default Devise :authenticate_user!
  def authenticate_user!
    super
    check_ip!
  end

  # Checks if request's remote IP matches the one set for the user during login
  # If not, it logs out user and redirects to the login page
  def check_ip!
    return if current_user.login_ip == request.remote_ip

    Rails.logger.warn "Request's remote IP not matches the one set for the user during login"
    sign_out current_user
    redirect_to new_user_session_path
  end

  # Redirects to root path and shows an error message if `CsvUploadFailureException` raised
  def handle_exception(exception)
    redirect_to(root_path, alert: exception.message)
  end

  # Function used as a rescue from API errors.
  # Logs the exception and renders service unavailable page
   # :nocov:
  def render_service_unavailable(exception)
    Rails.logger.error "#{exception.class}: #{exception}"

    render template: 'errors/service_unavailable', status: :service_unavailable
  end
   # :nocov:

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(_resource_or_scope)
    user_session_path
  end

  # Assign back button url
  def assign_back_button_url
    @back_button_url = request.referer || root_path
  end

  # Checks if hosts were not manipulated
  # :nocov:
  def validate_host_headers!
    Security::HostHeaderValidator.call(request: request, allowed_hosts: Rails.configuration.x.host)
  end
  # :nocov:
end
