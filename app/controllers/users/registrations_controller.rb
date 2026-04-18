# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  layout "devise"

  before_action :configure_permitted_parameters

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:role])
  end
end
