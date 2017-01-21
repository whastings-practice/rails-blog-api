require 'rails_helper'

RSpec.describe UserSerializer, type: :serializer do
  let(:user) { build(:user) }
  let(:serialized_user) { ActiveModelSerializers::SerializableResource.new(user).as_json }

  it "does not include sensitive fields in output" do
    [:password, :password_digest, :password_confirmation].each do |field|
      expect(serialized_user[field]).to be(nil)
    end
  end
end
