require 'rails_helper'

RSpec.feature "Home Page" do
  scenario "viewing about me content" do
    visit "/"
    about_me_section = find(".home-about-me")
    about_me_header = about_me_section.find("h2")
    about_me_content = about_me_section.find("p")

    expect(about_me_header).to have_content("About Me")
    expect(about_me_content).to have_content("I'm Will")
  end
end
