module BasicAuthHelper
  def login_as(district)
    user = district.name.downcase
    pw = "#{district.name.downcase}!"
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user, pw)
  end
end
