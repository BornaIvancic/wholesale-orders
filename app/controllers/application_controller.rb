# frozen_string_literal: true

class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound do
    redirect_to root_path, alert: 'Traženi zapis ne postoji ili nemate pristup.'
  end

  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_root_path
    elsif resource.partner_user?
      orders_path
    else
      root_path
    end
  end

  private

  def user_not_authorized
    redirect_to root_path, alert: 'Nemate ovlasti za pristup toj stranici.'
  end
end