# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170121205458) do

  create_table "posts", force: :cascade do |t|
    t.string   "title",                        null: false
    t.text     "body",                         null: false
    t.string   "permalink",                    null: false
    t.string   "image_url"
    t.boolean  "published",    default: false, null: false
    t.date     "publish_date"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["permalink"], name: "index_posts_on_permalink", unique: true
    t.index ["published"], name: "index_posts_on_published"
    t.index ["title"], name: "index_posts_on_title", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "token",      null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_sessions_on_token", unique: true
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "username",        null: false
    t.string   "password_digest", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["username"], name: "index_users_on_username", unique: true
  end

end
