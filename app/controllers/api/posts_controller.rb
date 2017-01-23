require_relative './concerns/authentication_concern'

class Api::PostsController < ApplicationController
  include Api::AuthenticationConcern

  before_action :require_current_user, except: [:index]

  def index
    posts = Post.all
    render json: posts
  end

  def create
    post = current_user.posts.build(post_params)

    if post.save
      render json: post
    else
      render json: { errors: post.errors }, status: 422
    end
  end

  private

    def post_params
      params.require(:post).permit(:title, :body)
    end
end
