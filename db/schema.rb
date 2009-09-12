# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090905032202) do

  create_table "items", :force => true do |t|
    t.string   "author"
    t.string   "text"
    t.string   "fullMessage"
    t.datetime "submitted"
    t.integer  "list_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "deleted",     :default => false
  end

  create_table "lists", :force => true do |t|
    t.string   "name"
    t.string   "owner"
    t.string   "permission"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "deleted",    :default => false
    t.string   "regexp"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.integer  "twitter_id"
    t.integer  "last_mention"
    t.integer  "last_dm"
    t.boolean  "welcomed",     :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
