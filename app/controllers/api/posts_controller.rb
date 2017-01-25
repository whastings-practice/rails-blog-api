require_relative './concerns/authentication_concern'

class Api::PostsController < ApplicationController
  include Api::AuthenticationConcern

  before_action :require_current_user, except: [:index, :show]

  def index
    posts = Post.all
    render json: posts
  end

  def show
    conditions = { id: params[:id] }
    conditions[:published] = true unless current_user
    post = Post.find_by(conditions)

    if post
      render json: post
    else
      head 404
    end
  end

  def create
    post = current_user.posts.build(post_params)

    if post.save
      render json: post
    else
      render json: { errors: post.errors }, status: 422
    end
  end

  def update
    post = current_user.posts.find(params[:id])

    if post.update(post_params)
      render json: post
    else
      render json: { errors: post.errors }, status: 422
    end
  rescue ActiveRecord::RecordNotFound
    head 404
  end

  def destroy
    post = current_user.posts.find(params[:id])
    post.destroy!
    head 200
  rescue ActiveRecord::RecordNotFound
    head 404
  end

  private

    def post_params
      params.require(:post).permit(:title, :body)
    end
end
