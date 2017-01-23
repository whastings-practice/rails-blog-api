require 'json'
require 'rails_helper'

RSpec.describe Api::PostsController, type: :controller do
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
end
