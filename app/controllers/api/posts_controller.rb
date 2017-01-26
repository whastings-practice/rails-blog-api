class Api::PostsController < ApplicationController
  include Api::AuthenticationConcern

  before_action :require_current_user, except: [:index, :show]

  serialization_scope :post_serializer_scope

  def index
    conditions = {}
    conditions[:published] = true unless current_user && params[:includeUnpublished]
    posts = Post.where(conditions)

    render json: posts
  end

  def show
    conditions = { permalink: params[:permalink] }
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
      params.require(:post).permit(:title, :body, :published)
    end

    def post_serializer_scope
      @post_serializer_scope ||= begin
        scope = {}
        scope[:is_editable] = true if params[:editable]
        scope
      end
    end
end
