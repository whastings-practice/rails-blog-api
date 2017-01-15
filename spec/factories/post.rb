FactoryGirl.define do
  factory :post do
    title "Post Title"
    body "Post body."
    permalink "post-title"
    image_url "http://example.com/example.jpg"
    published true
  end
end
