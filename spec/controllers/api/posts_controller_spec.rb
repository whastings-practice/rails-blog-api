require 'json'
require 'rails_helper'

RSpec.describe Api::PostsController, type: :controller do
  include ControllerSpecHelpers

  def expect_data_for_post(post_data, post)
    [:id, :title, :permalink].each do |attr|
      expect(post_data[attr.to_s]).to eq(post.send(attr))
    end
  end

  describe "index" do
    it "responds with a list of all posts" do
      posts = []
      5.times { posts << create(:post) }
      get :index
      posts_data = JSON.parse(response.body)

      expect(response.status).to be(200)
      expect(posts_data.length).to be(posts.length)
      posts_data.each_with_index do |post_data, i|
        expect_data_for_post(post_data, posts[i])
      end
    end
  end

  describe "create" do
    let(:input) { { title: "Foo Bar", body: "Baz qux" } }
    let(:user) { create(:user) }

    it "creates a post and returns its data" do
      sign_in(user)
      post :create, params: { post: input }
      new_post = Post.last

      expect(response.status).to be(200)
      expect(new_post.title).to eq(input[:title])
      expect(new_post.body).to eq(input[:body])
      expect(user.posts.last.id).to be(new_post.id)
      post_data = JSON.parse(response.body)
      expect_data_for_post(post_data, new_post)
    end

    it "does not create a post if user is not signed in" do
      post :create, params: { post: input }

      expect(response.status).to be(401)
      expect(Post.last).to be_nil
    end

    it "does not create a post and returns errors if post is invalid" do
      sign_in(user)
      input[:body] = ""
      post :create, params: { post: input }
      errors_data = JSON.parse(response.body)["errors"]

      expect(response.status).to be(422)
      expect(Post.last).to be_nil
      expect(errors_data["body"][0]).to eq("can't be blank")
    end
  end
end
