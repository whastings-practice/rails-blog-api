require 'rails_helper'

RSpec.feature "Home Page" do
  scenario "viewing about me content" do
    visit "/"
    about_me_section = find(".home-about-me")
    about_me_heading = about_me_section.find("h2")
    about_me_content = about_me_section.find("p")

    expect(about_me_heading).to have_content("About Me")
    expect(about_me_content).to have_content("I'm Will")
  end

  scenario "viewing recent posts" do
    posts = []
    5.times { posts << create(:post, publish_date: "2017-1-1") }
    visit "/"
    recent_posts_section = find(".home-recent-posts")
    recent_posts_heading = recent_posts_section.find(".section-title")
    post_teasers = recent_posts_section.all(".post-teaser")

    expect(recent_posts_heading).to have_content("Recent Posts")
    post_teasers.each_with_index do |post_teaser, i|
      post = posts[i]
      post_heading = post_teaser.find(".post-teaser__title")
      publish_date = post_teaser.find(".post-teaser__publish-date")
      preview = post_teaser.all("p").last

      expect(post_heading).to have_content(post.title)
      expect(post_heading.find("a")[:href]).to include("/blog/#{post.permalink}")
      expect(publish_date).to have_content("January 1, 2017")
      expect(preview).to have_content(post.body)
    end
  end
end
