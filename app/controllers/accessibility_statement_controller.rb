# frozen_string_literal: true

##
# Controller class for the accessibility statement page
#
class AccessibilityStatementController < ApplicationController
  # assign back button path
  before_action :assign_back_button_url, only: %i[index]
  ##
  # Renders the static cookies page
  #
  # ==== Path
  #    GET /accessibility_statement
  #
  def index
    # renders static page
  end
end
