module Admin
  class DashboardController < ApplicationController
    before_action :authenticate_user!

    def index
      authorize :admin, :access?
    end
  end
end