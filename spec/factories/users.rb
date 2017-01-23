FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "will#{n}" }
    password "foobar"
    password_confirmation "foobar"
  end
end
