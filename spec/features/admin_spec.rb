require 'rails_helper'

RSpec.feature "Admin" do
  let(:user) { create(:user) }

  def sign_in
    visit "/admin/sign-in"
    sign_in_form = find(".sign-in-form")
    sign_in_form.fill_in("Username:", with: user.username)
    sign_in_form.fill_in("Password:", with: user.password)
    click_button("Go")
  end

  scenario "signing in" do
    visit "/admin"

    expect(page).to have_current_path("/admin/sign-in")

    sign_in

    expect(page).to have_current_path("/admin")
    expect(page).to have_content("Your Posts")
  end

  scenario "signing out" do
    sign_in
    click_button("Sign Out")

    expect(page).to have_current_path("/")

    visit("/admin")

    expect(page).to have_current_path("/admin/sign-in")
  end

  scenario "viewing all posts" do
    posts = []
    5.times { posts << create(:post, user: user) }
    sign_in

    post_index = find(".admin-post-index")
    post_teasers = post_index.all(".post-teaser")

    expect(post_index.find("h2.section-title")).to have_content("Your Posts")
    post_teasers.each_with_index do |post_teaser, i|
      post = posts[i]
      heading = post_teaser.find("h3.post-teaser__title")
      edit_link = post_teaser.find("a.admin-post-controls__edit-link")
      delete_button = post_teaser.find("button.admin-post-controls__delete-btn")

      expect(heading).to have_content(post.title)
      expect(heading.find("a")[:href]).to include("/blog/#{post.permalink}")
      expect(edit_link).to have_content("Edit")
      expect(edit_link[:href]).to include("/admin/posts/#{post.permalink}/edit")
      expect(delete_button).to have_content("Delete")
    end
  end

  scenario "creating a post" do
    sign_in
    click_link("New Post")
    fill_in("Title", with: "Foo Bar")
    fill_in("Body", with: "Baz qux.")
    within_fieldset("Published") { choose("Yes") }
    click_button("Submit")

    expect(page).to have_current_path("/blog/foo-bar")
    expect(find(".page-title")).to have_content("Foo Bar")
    expect(find(".post__body")).to have_content("Baz qux.")

    visit "/"

    expect(find(".post-teaser__title")).to have_content("Foo Bar")
  end

  scenario "editing a post" do
    post = create(:post, user: user)
    sign_in
    post_teaser = find(".post-teaser")

    expect(post_teaser).to have_content(post.title)

    post_teaser.click_link("Edit")

    expect(find("#post-form__title-input")[:value]).to eq(post.title)
    expect(find("#post-form__body-input")).to have_content(post.body)

    fill_in("Title", with: "Edited Post")
    fill_in("Body", with: "Edited post body.")
    click_button("Submit")

    expect(page).to have_current_path("/blog/edited-post")
    expect(find(".page-title")).to have_content("Edited Post")
    expect(find(".post__body")).to have_content("Edited post body.")
  end

  scenario "deleting a post" do
    post = create(:post, user: user)
    sign_in
    post_teaser = find(".post-teaser")
    post_teaser.click_button("Delete")

    expect(page).to have_current_path("/admin")
    expect(page).to have_no_selector(".post-teaser")
    expect(Post.exists?(post.id)).to be(false)
  end
end
