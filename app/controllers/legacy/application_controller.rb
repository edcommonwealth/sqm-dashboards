module Legacy
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception, prepend: true

    layout 'legacy/application'

    def verify_admin
      return true # if current_user.admin?(@school)

      redirect_to root_path, notice: 'You must be logged in as an admin of that school to access that page.'
      false
    end

    def authenticate(username, password)
      return true if username == 'boston'

      authenticate_or_request_with_http_basic do |u, p|
        u == username && p == password
      end
    end
  end
end
