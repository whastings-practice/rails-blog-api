require 'rails_helper'

RSpec.describe PostSerializer, type: :serializer do
  let(:post) { build(:post) }
  let(:serialized_post) { ActiveModelSerializers::SerializableResource.new(post).as_json }

  it "directly serializes basic attributes" do
    [:id, :title, :permalink, :published, :publish_date, :image_url].each do |attr|
      expect(serialized_post[attr]).to eq(post.send(attr))
    end
  end

  it "parses markdown in post body" do
    post.body = <<-BODY.strip_heredoc.strip
      # Foo Bar

      Foo bar baz.

      Qux mux.
    BODY

    serialized_body = "<h1>Foo Bar</h1>\n\n<p>Foo bar baz.</p>\n\n<p>Qux mux.</p>\n"

    expect(serialized_post[:body]).to eq(serialized_body)
  end

  it "provides preview with body content" do
    expect(serialized_post[:preview]).to eq(serialized_post[:body])
  end

  it "provides preview with excerpt of body content if marked" do
    post.body = <<-BODY.strip_heredoc.strip
      # Foo Bar

      [PREVIEW]
      Foo bar baz.
      [/PREVIEW]

      Qux mux.
    BODY

    expect(serialized_post[:preview]).to eq("<p>Foo bar baz.</p>\n")
  end
end
