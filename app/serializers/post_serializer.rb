class PostSerializer < ActiveModel::Serializer
  MARKDOWN = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  PREVIEW_START_STR = "[PREVIEW]"

  attributes :id, :title, :body, :permalink, :published, :publish_date, :image_url, :preview
  attribute :body_raw, if: -> { scope && scope[:is_editable] }

  def body
    set_body_and_preview
    @body
  end

  def body_raw
    object.body
  end

  def preview
    set_body_and_preview
    @preview
  end

  private

    def set_body_and_preview
      return if @body && @preview

      orig_body = object.body

      if orig_body.include?(PREVIEW_START_STR)
        before_preview, preview, after_preview = orig_body.split(/(?:\[PREVIEW\]|\[\/PREVIEW\])/)
        @body = MARKDOWN.render(before_preview + preview + after_preview)
        @preview = MARKDOWN.render(preview)
      else
        @body = MARKDOWN.render(orig_body)
        @preview = @body
      end
    end
end
