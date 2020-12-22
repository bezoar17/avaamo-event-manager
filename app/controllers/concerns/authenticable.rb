module Authenticable

  # assumption that auth is already done, and we have the current_user
  # using a dummy method for auth here
  def current_user
    @current_user ||= User.find_by(username: request.headers['username'])
  end
end