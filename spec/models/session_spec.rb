require 'rails_helper'

RSpec.describe Session, type: :model do
  describe "validations" do
    include ModelSpecHelpers

    it "requires a token" do
      session = build(:session)
      session.token = nil
      expect(session).to_not be_valid
      expect_field_has_error(session, :token)

      session.token = "abc123"
      expect(session).to be_valid
    end

    it "requires a user" do
      session = build(:session, user: nil)
      expect(session).to_not be_valid
      expect_field_has_error(session, :user)

      session.user = build(:user)
      expect(session).to be_valid
    end
  end

  describe "initialization" do
    it "creates a token on initialization" do
      session = Session.new(user: build(:user))
      expect(session.token).to_not be_blank
      expect(session).to be_valid
    end
  end
end
