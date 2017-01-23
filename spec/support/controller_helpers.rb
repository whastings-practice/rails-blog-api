module ControllerSpecHelpers
  def sign_in(user)
    session = user.sessions.create!
    request.cookies["session_token"] = session.token
  end
end
