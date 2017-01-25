require 'json'
require 'rails_helper'

RSpec.describe Api::PostsController, type: :controller do
  include ControllerSpecHelpers

  def expect_data_for_post(post_data, post)
    [:id, :title, :permalink].each do |attr|
      expect(post_data[attr.to_s]).to eq(post.send(attr))
    end
  end

  def expect_post_matches_input(post)
    expect(post.title).to eq(input[:title])
    expect(post.body).to eq(input[:body])
  end

  let(:input) { { title: "Foo Bar", body: "Baz qux" } }
  let(:new_post) { user.posts.create!(input.merge(published: true)) }
  let(:user) { create(:user) }

  describe "index" do
    def expect_no_unpublished(posts_data)
      expect(posts_data.length).to be(posts.length)
      expect(
        posts.none? { |post| post.id == unpublished_post.id }
      ).to be(true)
    end

    let!(:posts) do
      [].tap do |posts|
        5.times { posts << create(:post) }
      end
    end

    let!(:unpublished_post) { create(:post, published: false) }

    it "responds with a list of all posts" do
      get :index
      posts_data = JSON.parse(response.body)

      expect(response.status).to be(200)
      expect(posts_data.length).to be(posts.length)
      posts_data.each_with_index do |post_data, i|
        expect_data_for_post(post_data, posts[i])
      end
    end

    it "does not include unpublished posts by default" do
      get :index
      posts_data = JSON.parse(response.body)

      expect_no_unpublished(posts_data)
    end

    it "does include unpublished posts if user signed in and passed query param" do
      sign_in(user)
      get :index, params: { includeUnpublished: true }
      posts_data = JSON.parse(response.body)

      expect(posts_data.length).to be(posts.length + 1)
      expect_data_for_post(posts_data.last, unpublished_post)
    end

    it "does not include unpublished posts if user is signed in but no query param" do
      sign_in(user)
      get :index
      posts_data = JSON.parse(response.body)

      expect_no_unpublished(posts_data)
    end

    it "does not include unpublished posts if query param but user not signed in" do
      get :index, params: { includeUnpublished: true }
      posts_data = JSON.parse(response.body)

      expect_no_unpublished(posts_data)
    end
  end

  describe "show" do
    def view_post(permalink)
      get :show, params: { permalink: permalink }
    end

    let(:unpublished_post) { create(:post, published: false) }

    it "returns data for a post" do
      view_post(new_post.permalink)
      post_data = JSON.parse(response.body)

      expect(response.status).to be(200)
      expect_data_for_post(post_data, new_post)
    end

    it "returns 404 for a post that does not exist" do
      view_post("foo-bar-baz")

      expect(response.status).to be(404)
    end

    it "returns 404 if post exists but is not published" do
      view_post(unpublished_post.permalink)

      expect(response.status).to be(404)
    end

    it "returns data for post if post is unpublished and user is signed in" do
      sign_in(user)
      view_post(unpublished_post.permalink)

      expect(response.status).to be(200)
      post_data = JSON.parse(response.body)
      expect_data_for_post(post_data, unpublished_post)
    end
  end

  describe "create" do
    def create_post(data)
      post :create, params: { post: data }
    end

    it "creates a post and returns its data" do
      sign_in(user)
      create_post(input)
      new_post = Post.last
      post_data = JSON.parse(response.body)

      expect(response.status).to be(200)
      expect_post_matches_input(new_post)
      expect(user.posts.last.id).to be(new_post.id)
      expect_data_for_post(post_data, new_post)
    end

    it "does not create a post if user is not signed in" do
      create_post(input)

      expect(response.status).to be(401)
      expect(Post.last).to be_nil
    end

    it "does not create a post and returns errors if post is invalid" do
      sign_in(user)
      input[:body] = ""
      create_post(input)
      errors_data = JSON.parse(response.body)["errors"]

      expect(response.status).to be(422)
      expect(Post.last).to be_nil
      expect(errors_data["body"][0]).to eq("can't be blank")
    end
  end

  describe "update" do
    def update_post(id, data)
      patch :update, params: { id: id, post: data }
    end

    it "updates a post and returns its data" do
      sign_in(user)
      input[:body] = "Baz qux biz."
      update_post(new_post.id, body: input[:body])
      updated_post = Post.last
      post_data = JSON.parse(response.body)

      expect(response.status).to be(200)
      expect_post_matches_input(updated_post)
      expect_data_for_post(post_data, updated_post)
    end

    it "does not update a post if user is not signed in" do
      update_post(new_post.id, body: "Updated!")
      new_post.reload

      expect(response.status).to be(401)
      expect(response.body).to be_blank
      expect_post_matches_input(new_post)
    end

    it "returns 404 if post does not exist" do
      sign_in(user)
      update_post(100, body: "Updated!")

      expect(response.status).to be(404)
      expect(response.body).to be_blank
    end

    it "returns 404 if post does not belong to current user" do
      sign_in(user)
      other_new_post = create(:user).posts.create!(input)
      update_post(other_new_post.id, body: "Updated!")
      other_new_post.reload

      expect(response.status).to be(404)
      expect(response.body).to be_blank
      expect_post_matches_input(other_new_post)
    end

    it "does not update post and returns errors if post is invalid" do
      sign_in(user)
      update_post(new_post.id, body: "")
      new_post.reload
      errors_data = JSON.parse(response.body)["errors"]

      expect(response.status).to be(422)
      expect_post_matches_input(new_post)
      expect(errors_data["body"][0]).to eq("can't be blank")
    end
  end

  describe "destroy" do
    def destroy_post(id)
      delete :destroy, params: { id: id }
    end

    it "destroys post" do
      sign_in(user)
      destroy_post(new_post.id)

      expect(response.status).to be(200)
      expect(Post.exists?(id: new_post.id)).to be(false)
    end

    it "does not delete post if user is not signed in" do
      destroy_post(new_post.id)

      expect(response.status).to be(401)
      expect(Post.exists?(id: new_post.id)).to be(true)
    end

    it "returns 404 if post does not exist" do
      sign_in(user)
      destroy_post(50)

      expect(response.status).to be(404)
    end

    it "does not destroy post if post does not belong to current user" do
      sign_in(user)
      other_new_post = create(:user).posts.create!(input)
      destroy_post(other_new_post.id)

      expect(response.status).to be(404)
      expect(Post.exists?(id: other_new_post.id)).to be(true)
    end
  end
end
