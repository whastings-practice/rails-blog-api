class Api::SessionsController < ApplicationController
  def create
    user = User.find_by(username: params[:user][:username])

    if user.try(:authenticate, params[:user][:password])
      session = user.sessions.create!
      cookies.encrypted[:session_token] = { value: session.token, httponly: true }
      render json: session
    else
      head 403
    end
  end
end
