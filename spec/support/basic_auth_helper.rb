module BasicAuthHelper
  def login_as(district)
    user = district.username
    pw = district.password
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user, pw)
  end
end
