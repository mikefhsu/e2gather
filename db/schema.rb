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

ActiveRecord::Schema.define(version: 20131015045755) do

  create_table "events", force: true do |t|
    t.integer  "event_id",        null: false
    t.string   "name",            null: false
    t.string   "location",        null: false
    t.datetime "date_time",       null: false
    t.integer  "host",            null: false
    t.text     "ingredient_list"
    t.text     "guest_list"
    t.boolean  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ingredients", force: true do |t|
    t.integer  "ingredient_id", null: false
    t.string   "name",          null: false
    t.float    "quantity",      null: false
    t.string   "unit",          null: false
    t.integer  "user_id",       null: false
    t.boolean  "brought"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.integer  "user_id",           null: false
    t.string   "name",              null: false
    t.string   "email",             null: false
    t.text     "refrigerator_list"
    t.text     "event_list"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
