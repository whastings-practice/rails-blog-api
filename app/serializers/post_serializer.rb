class PostSerializer < ActiveModel::Serializer
  MARKDOWN = Redcarpet::Markdown.new(Redcarpet::Render::HTML)

  attributes :id, :title, :body, :permalink, :published, :publish_date, :image_url

  def body
    MARKDOWN.render(object.body)
  end
end
