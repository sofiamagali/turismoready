class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    additional_attributes = %i[first_name last_name phone]
    devise_parameter_sanitizer.permit(:sign_up, keys: additional_attributes)
    devise_parameter_sanitizer.permit(:account_update, keys: additional_attributes)
  end
end
