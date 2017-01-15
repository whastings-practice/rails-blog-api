require 'date'

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

def create_fake_post(attributes = {})
  Post.create!({
    title: Faker::Lorem.sentence(5).titleize,
    body: Faker::Lorem.paragraphs.join("\n\n"),
    published: true,
    publish_date: Date.today
  }.merge(attributes))
end

ActiveRecord::Base.transaction do
  10.times do
    create_fake_post
  end

  3.times do
    create_fake_post(published: false, publish_date: nil)
  end
end
