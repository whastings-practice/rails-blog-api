require 'rails_helper'

RSpec.describe PostSerializer, type: :serializer do
  let(:session) { build(:session) }
  let(:serialized_session) { ActiveModelSerializers::SerializableResource.new(session).as_json }

  it "serializes session with user data" do
    expect(serialized_session.keys.length).to be(1)

    user_data = serialized_session[:user]
    expect(user_data.keys.length).to be(2)
    expect(user_data[:id]).to eq(session.user.id)
    expect(user_data[:username]).to eq(session.user.username)
  end
end
