module Api::AuthenticationConcern
  extend ActiveSupport::Concern

  private

    def current_user
      cookies[:session_token].try(:tap) do |token|
        return Session.find_by(token: token).try(:user)
      end

      nil
    end

    def require_current_user
      head 401 unless current_user
    end
end
