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

ActiveRecord::Schema.define(version: 20150824085148) do

  create_table "collaborations", force: :cascade do |t|
    t.boolean  "is_admin",   limit: 1
    t.integer  "user_id",    limit: 4
    t.integer  "note_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "collaborations", ["user_id", "note_id"], name: "index_collaborations_on_user_id_and_note_id", using: :btree

  create_table "notes", force: :cascade do |t|
    t.text     "content",    limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "notes_tags", id: false, force: :cascade do |t|
    t.integer  "note_id",    limit: 4
    t.integer  "tag_id",     limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "notes_tags", ["note_id", "tag_id"], name: "index_notes_tags_on_note_id_and_tag_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "note_id",    limit: 4
    t.boolean  "is_seen",    limit: 1,   default: false
    t.string   "from_user",  limit: 255
    t.boolean  "is_removed", limit: 1,   default: false
    t.boolean  "rejected",   limit: 1,   default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "notifications", ["user_id", "note_id"], name: "index_notifications_on_user_id_and_note_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "tagname",    limit: 30
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "tags", ["tagname"], name: "index_tags_on_tagname", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username",        limit: 50
    t.string   "email",           limit: 50
    t.text     "password_digest", limit: 65535
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "users", ["username"], name: "index_users_on_username", using: :btree

end
