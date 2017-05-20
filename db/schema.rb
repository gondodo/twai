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

ActiveRecord::Schema.define(version: 20170520004518) do

  create_table "birds", force: :cascade do |t|
    t.string   "account"
    t.string   "tweet"
    t.string   "post"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gourmets", force: :cascade do |t|
    t.string   "station_name"
    t.string   "genre"
    t.integer  "cost"
    t.string   "status"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "last_dialogue_infos", force: :cascade do |t|
    t.string   "mid"
    t.string   "mode"
    t.integer  "da"
    t.string   "context"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "text_message"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "prefs", force: :cascade do |t|
    t.integer  "pref_cd"
    t.string   "pref_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stations", force: :cascade do |t|
    t.integer  "station_cd"
    t.integer  "station_g_cd"
    t.string   "station_name"
    t.integer  "line_cd"
    t.integer  "pref_cd"
    t.string   "post"
    t.string   "add"
    t.float    "lon"
    t.float    "lat"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "tabelogs", force: :cascade do |t|
    t.integer  "gourmet_id"
    t.string   "rst_name"
    t.float    "hoshi"
    t.string   "url"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "img_url"
    t.string   "text"
    t.string   "lunch_cost"
    t.string   "dinner_cost"
  end

  create_table "users", force: :cascade do |t|
    t.string   "mid"
    t.string   "display_name"
    t.integer  "status"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

end
