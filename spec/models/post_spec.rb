require 'rails_helper'

RSpec.describe Post, type: :model do
  describe "validations" do
    include ModelSpecHelpers

    it "requires a title" do
      post = build(:post, title: nil)
      expect(post).to_not be_valid
      expect_field_has_error(post, :title)

      post.title = "Foo"
      expect(post).to be_valid
    end

    it "requires a body" do
      post = build(:post, body: nil)
      expect(post).to_not be_valid
      expect_field_has_error(post, :body)

      post.body = "Bar"
      expect(post).to be_valid
    end

    it "requires a permalink" do
      post = build(:post, title: nil, permalink: nil)
      expect(post).to_not be_valid
      expect_field_has_error(post, :permalink)

      post.permalink = "foo"
      post.title = "bar"
      expect(post).to be_valid
    end

    it "requires published" do
      post = build(:post, published: nil)
      expect(post).to_not be_valid
      expect_field_has_error(post, :published)

      post.published = true
      expect(post).to be_valid
    end

    it "requires published to be a boolean" do
      post = build(:post, published: nil)
      expect(post).to_not be_valid
      expect_field_has_error(post, :published)

      post.published = false
      expect(post).to be_valid
    end
  end

  describe "initialization" do
    it "sets permalink based on title" do
      post = Post.new(title: "Foo Bar", body: "Foo")
      expect(post.permalink).to eq("foo-bar")
    end
  end
end
