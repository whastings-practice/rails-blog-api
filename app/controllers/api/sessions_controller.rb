class Api::SessionsController < ApplicationController
  def create
    user = User.find_by(username: params[:user][:username])

    if user.try(:authenticate, params[:user][:password])
      session = user.sessions.create!
      cookies[:session_token] = { value: session.token, httponly: true }
      render json: session
    else
      head 403
    end
  end

  def destroy
    cookies[:session_token].try(:tap) do |token|
      session = Session.find_by(token: token)
      if session
        session.destroy!
        cookies[:session_token] = nil
        return head 200
      end
    end

    head 404
  end
end
