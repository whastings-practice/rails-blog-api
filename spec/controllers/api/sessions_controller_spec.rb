require 'json'
require 'rails_helper'

RSpec.describe Api::SessionsController, type: :controller do
  let(:user) { create(:user) }

  def sign_in
    post :create, params: { user: { username: user.username, password: user.password } }
  end

  describe "create" do
    def expect_rejection_response
      expect(response.status).to be(403)
      expect(cookies[:session_token]).to_not be_present
      expect(user.sessions.length).to be(0)
      expect(response.body).to be_blank
    end

    it "creates a session for an existing user" do
      sign_in
      user_data = JSON.parse(response.body)["user"]

      expect(response.status).to be(200)
      expect(cookies[:session_token]).to be_present
      expect(user.sessions.length).to be(1)
      expect(user_data.keys.length).to be(2)
      expect(user_data["id"]).to be(user.id)
      expect(user_data["username"]).to eq(user.username)
    end

    it "does not create a session for a non-existing user" do
      post :create, params: { user: { username: "foo", password: user.password } }

      expect_rejection_response
    end

    it "does not create a session for a wrong password" do
      post :create, params: { user: { username: user.username, password: "bazqux" } }

      expect_rejection_response
    end
  end

  describe "destroy" do
    it "destroys the session for the current user" do
      sign_in
      delete :destroy

      expect(response.status).to be(200)
      expect(cookies[:session_token]).to_not be_present
      expect(user.sessions).to be_empty
      expect(response.body).to be_blank
    end

    it "sends 404 if no session token" do
      delete :destroy

      expect(response.status).to be(404)
      expect(response.body).to be_blank
    end

    it "sends 404 if invalid session token" do
      sign_in
      user.sessions.update(token: "abc123")
      delete :destroy

      expect(response.status).to be(404)
      expect(cookies[:session_token]).to be_present
      expect(user.sessions.first).to_not be_destroyed
    end
  end
end
