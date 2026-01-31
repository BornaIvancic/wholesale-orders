class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    redirect_to(root_path, alert: "Nemate ovlasti za pristup toj stranici.")
  end
  class ProfileController < ApplicationController
    before_action :authenticate_user!

    def show
    end
  end
end
