module BasicAuthHelper
  def login_as(district)
    user = district.short_name
    pw = "#{user}!"
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user, pw)
  end
end
