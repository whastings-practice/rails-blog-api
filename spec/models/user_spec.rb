require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    include ModelSpecHelpers

    it "requires a username" do
      user = build(:user, username: nil)
      expect(user).to_not be_valid
      expect_field_has_error(user, :username)

      user.username = "will"
      expect(user).to be_valid
    end

    it "requires a password" do
      user = build(:user, password: nil)
      expect(user).to_not be_valid
      expect_field_has_error(user, :password)

      user.password = "foobar"
      expect(user).to be_valid
    end
  end

  describe "authentication" do
    it "supports password authentication" do
      user = User.new(username: "will", password: "foobar")
      user.save

      expect(user.authenticate("bazqux")).to be(false)
      expect(user.authenticate("foobar")).to be(user)
    end
  end
end
