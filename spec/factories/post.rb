FactoryGirl.define do
  factory :post do
    sequence(:title) { |n| "Post Title #{n}"}
    body "Post body."
    sequence(:permalink) { |n| "post-title-#{n}"}
    image_url "http://example.com/example.jpg"
    published true
    user
  end
end
