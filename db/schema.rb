# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160312194035) do

  create_table "code_checks", force: :cascade do |t|
    t.string   "code"
    t.boolean  "valid_univ_code"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "colleges", force: :cascade do |t|
    t.string   "code"
    t.string   "access_id"
    t.string   "password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "home_url"
  end

  create_table "job_postings", force: :cascade do |t|
    t.integer  "college_id"
    t.string   "company"
    t.string   "title"
    t.string   "desta_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "views"
    t.string   "status"
  end

  create_table "password_resets", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "token"
    t.datetime "used"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "password_digest"
    t.boolean  "admin"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "stripe_id"
  end

end
