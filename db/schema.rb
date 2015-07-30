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

ActiveRecord::Schema.define(version: 20150618011840) do

  create_table "categories", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.integer  "create_user_id", limit: 8
    t.integer  "update_user_id", limit: 8
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "connections", force: :cascade do |t|
    t.integer  "connect_kbn",    limit: 4
    t.integer  "from_user_id",   limit: 8
    t.integer  "to_user_id",     limit: 8
    t.integer  "target_id",      limit: 8
    t.integer  "create_user_id", limit: 8
    t.integer  "update_user_id", limit: 8
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "item_categories", force: :cascade do |t|
    t.integer  "item_id",        limit: 8, null: false
    t.integer  "category_id",    limit: 8, null: false
    t.integer  "create_user_id", limit: 8
    t.integer  "update_user_id", limit: 8
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "item_comments", force: :cascade do |t|
    t.integer  "item_id",        limit: 8
    t.string   "comment",        limit: 2000
    t.integer  "create_user_id", limit: 8
    t.integer  "update_user_id", limit: 8
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "item_favorites", force: :cascade do |t|
    t.integer  "item_id",        limit: 8
    t.integer  "create_user_id", limit: 8
    t.integer  "update_user_id", limit: 8
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "item_goods", force: :cascade do |t|
    t.integer  "item_id",        limit: 8
    t.integer  "user_id",        limit: 8
    t.integer  "create_user_id", limit: 8
    t.integer  "update_user_id", limit: 8
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "item_proposes", force: :cascade do |t|
    t.integer  "item_id",              limit: 8
    t.integer  "payment_kbn",          limit: 4
    t.integer  "price",                limit: 8
    t.date     "noki"
    t.integer  "hour_price",           limit: 4
    t.integer  "week_hour_kbn",        limit: 4
    t.integer  "week_hour_period_kbn", limit: 4
    t.string   "content",              limit: 255
    t.integer  "create_user_id",       limit: 8
    t.integer  "update_user_id",       limit: 8
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "items", force: :cascade do |t|
    t.integer  "work_kbn",             limit: 4
    t.integer  "payment_kbn",          limit: 4
    t.integer  "price",                limit: 8
    t.integer  "price_kbn",            limit: 4
    t.date     "noki"
    t.integer  "hour_price_kbn",       limit: 4
    t.integer  "week_hour_kbn",        limit: 4
    t.integer  "week_hour_period_kbn", limit: 4
    t.date     "limit_date"
    t.string   "title",                limit: 255
    t.text     "content",              limit: 65535
    t.string   "img_path",             limit: 255
    t.integer  "propose_count",        limit: 8,     default: 0
    t.integer  "view_count",           limit: 8,     default: 0
    t.integer  "favorite_count",       limit: 8,     default: 0
    t.integer  "preview_flg",          limit: 4,     default: 0
    t.integer  "create_user_id",       limit: 8
    t.integer  "update_user_id",       limit: 8
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "item_id",         limit: 4
    t.integer  "parent_id",       limit: 4
    t.integer  "send_user_id",    limit: 8
    t.integer  "receive_user_id", limit: 8
    t.string   "title",           limit: 255
    t.string   "content",         limit: 255
    t.integer  "create_user_id",  limit: 8
    t.integer  "update_user_id",  limit: 8
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "names", force: :cascade do |t|
    t.integer  "name_kbn",       limit: 4,                null: false
    t.integer  "parent_id",      limit: 4,                null: false
    t.string   "name",           limit: 255, default: "", null: false
    t.string   "content",        limit: 255,              null: false
    t.integer  "create_user_id", limit: 8
    t.integer  "update_user_id", limit: 8
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  create_table "notices", force: :cascade do |t|
    t.string   "title",          limit: 255
    t.string   "content",        limit: 255
    t.integer  "create_user_id", limit: 8
    t.integer  "update_user_id", limit: 8
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "notification_kbn", limit: 4
    t.integer  "target_id",        limit: 8
    t.integer  "user_id",          limit: 8
    t.integer  "create_user_id",   limit: 8
    t.integer  "update_user_id",   limit: 8
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "user_work_categories", force: :cascade do |t|
    t.integer  "user_id",        limit: 8
    t.integer  "name_id",        limit: 8
    t.integer  "create_user_id", limit: 8
    t.integer  "update_user_id", limit: 8
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "unique_id",      limit: 255
    t.string   "email",          limit: 255
    t.string   "password",       limit: 255
    t.integer  "email_auth_flg", limit: 4
    t.string   "display_name",   limit: 255
    t.string   "content",        limit: 2000
    t.string   "img_path",       limit: 255
    t.string   "img_file_name",  limit: 255
    t.string   "email_token",    limit: 255
    t.integer  "user_kbn",       limit: 4
    t.integer  "sex",            limit: 4
    t.date     "birthday"
    t.integer  "area",           limit: 4
    t.integer  "create_user_id", limit: 8
    t.integer  "update_user_id", limit: 8
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "users", ["email"], name: "email", unique: true, using: :btree

end
