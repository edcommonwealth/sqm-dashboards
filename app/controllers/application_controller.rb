class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, prepend: true


  def verify_admin
    return true #if current_user.admin?(@school)

    redirect_to root_path, notice: 'You must be logged in as an admin of that school to access that page.'
    return false
  end

end
