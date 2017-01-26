require 'date'

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

def create_fake_post(user, attributes = {})
  user.posts.create!({
    title: Faker::Lorem.sentence(5).titleize,
    body: Faker::Lorem.paragraphs.join("\n\n"),
    published: true,
    publish_date: Date.today
  }.merge(attributes))
end

ActiveRecord::Base.transaction do
  user = User.create!(username: "will", password: "foobar")

  10.times do
    create_fake_post(user)
  end

  3.times do
    create_fake_post(user, published: false, publish_date: nil)
  end
end
