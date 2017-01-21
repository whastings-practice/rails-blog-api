FactoryGirl.define do
  factory :session do
    token "abc123"
    user
  end
end
