class Api::PagesController < ApplicationController
  def home
    content = <<END
      <h2 id="about-me">About Me</h2>
      <p>I&#39;m Will, a front-end engineer and JavaScript enthusiast working on web apps
      at LinkedIn. I geek out over web performance, accessibilty, UI component
      development, and single-page app architecture.</p>
END
    render json: { content: content, id: "home" }
  end
end
