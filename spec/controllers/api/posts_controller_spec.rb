require 'json'
require 'rails_helper'

RSpec.describe Api::PostsController, type: :controller do
  include ControllerSpecHelpers

  def expect_data_for_post(post_data, post)
    [:id, :title, :permalink].each do |attr|
      expect(post_data[attr.to_s]).to eq(post.send(attr))
    end
  end

  let(:input) { { title: "Foo Bar", body: "Baz qux" } }
  let(:new_post) { user.posts.create!(input) }
  let(:user) { create(:user) }

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

  describe "update" do
    it "updates a post and returns its data" do
      sign_in(user)
      input[:body] = "Baz qux biz."
      patch :update, params: { id: new_post.id, post: { body: input[:body] } }
      updated_post = Post.last
      post_data = JSON.parse(response.body)

      expect(response.status).to be(200)
      expect(updated_post.title).to eq(input[:title])
      expect(updated_post.body).to eq(input[:body])
      expect_data_for_post(post_data, updated_post)
    end

    it "does not update a post if user is not signed in" do
      patch :update, params: { id: new_post.id, post: { body: "Updated!" } }
      new_post.reload

      expect(response.status).to be(401)
      expect(response.body).to be_blank
      expect(new_post.title).to eq(input[:title])
      expect(new_post.body).to eq(input[:body])
    end

    it "returns 404 if post does not exist" do
      sign_in(user)
      patch :update, params: { id: 100, post: { body: "Updated!" } }

      expect(response.status).to be(404)
      expect(response.body).to be_blank
    end

    it "returns 404 if post does not belong to current user" do
      sign_in(user)
      other_new_post = create(:user).posts.create!(input)
      patch :update, params: { id: other_new_post.id, post: { body: "Updated!" } }
      other_new_post.reload

      expect(response.status).to be(404)
      expect(response.body).to be_blank
      expect(other_new_post.body).to eq(input[:body])
    end

    it "does not update post and returns errors if post is invalid" do
      sign_in(user)
      patch :update, params: { id: new_post.id, post: { body: "" } }
      new_post.reload
      errors_data = JSON.parse(response.body)["errors"]

      expect(response.status).to be(422)
      expect(new_post.body).to eq(input[:body])
      expect(errors_data["body"][0]).to eq("can't be blank")
    end
  end

  describe "destroy" do
    it "destroys post" do
      sign_in(user)
      delete :destroy, params: { id: new_post.id }

      expect(response.status).to be(200)
      expect(Post.exists?(id: new_post.id)).to be(false)
    end

    it "does not delete post if user is not signed in" do
      delete :destroy, params: { id: new_post.id }

      expect(response.status).to be(401)
      expect(Post.exists?(id: new_post.id)).to be(true)
    end

    it "returns 404 if post does not exist" do
      sign_in(user)
      delete :destroy, params: { id: 50 }

      expect(response.status).to be(404)
    end

    it "does not destroy post if post does not belong to current user" do
      sign_in(user)
      other_new_post = create(:user).posts.create!(input)
      delete :destroy, params: { id: other_new_post.id }

      expect(response.status).to be(404)
      expect(Post.exists?(id: other_new_post.id)).to be(true)
    end
  end
end
