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

ActiveRecord::Schema.define(version: 20170418173141) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attempts", force: :cascade do |t|
    t.integer  "recipient_id"
    t.integer  "schedule_id"
    t.integer  "recipient_schedule_id"
    t.datetime "sent_at"
    t.datetime "responded_at"
    t.integer  "question_id"
    t.integer  "translation_id"
    t.integer  "answer_index"
    t.integer  "open_response_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.text     "twilio_details"
    t.string   "twilio_sid"
    t.integer  "student_id"
    t.index ["twilio_sid"], name: "index_attempts_on_twilio_sid", using: :btree
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.string   "blurb"
    t.text     "description"
    t.string   "external_id"
    t.integer  "parent_category_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "slug"
    t.index ["slug"], name: "index_categories_on_slug", unique: true, using: :btree
  end

  create_table "districts", force: :cascade do |t|
    t.string   "name"
    t.integer  "state_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "question_lists", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.text     "question_ids"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "questions", force: :cascade do |t|
    t.string   "text"
    t.string   "option1"
    t.string   "option2"
    t.string   "option3"
    t.string   "option4"
    t.string   "option5"
    t.integer  "category_id"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "target_group",           default: 0
    t.boolean  "for_recipient_students", default: false
  end

  create_table "recipient_lists", force: :cascade do |t|
    t.integer  "school_id"
    t.string   "name"
    t.text     "description"
    t.text     "recipient_ids"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["school_id"], name: "index_recipient_lists_on_school_id", using: :btree
  end

  create_table "recipient_schedules", force: :cascade do |t|
    t.integer  "recipient_id"
    t.integer  "schedule_id"
    t.text     "upcoming_question_ids"
    t.text     "attempted_question_ids"
    t.datetime "last_attempt_at"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.datetime "next_attempt_at"
    t.string   "queued_question_ids"
  end

  create_table "recipients", force: :cascade do |t|
    t.string   "name"
    t.string   "phone"
    t.date     "birth_date"
    t.string   "gender"
    t.string   "race"
    t.string   "ethnicity"
    t.integer  "home_language_id"
    t.string   "income"
    t.boolean  "opted_out",        default: false
    t.integer  "school_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "email"
    t.string   "slug"
    t.integer  "attempts_count",   default: 0
    t.integer  "responses_count",  default: 0
    t.string   "teacher"
    t.index ["phone"], name: "index_recipients_on_phone", using: :btree
    t.index ["slug"], name: "index_recipients_on_slug", unique: true, using: :btree
  end

  create_table "schedules", force: :cascade do |t|
    t.integer  "school_id"
    t.string   "name"
    t.text     "description"
    t.integer  "frequency_hours",   default: 24
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "active",            default: true
    t.boolean  "random",            default: false
    t.integer  "recipient_list_id"
    t.integer  "question_list_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "time",              default: 960
    t.index ["school_id"], name: "index_schedules_on_school_id", using: :btree
  end

  create_table "school_categories", force: :cascade do |t|
    t.integer  "school_id"
    t.integer  "category_id"
    t.integer  "attempt_count",      default: 0
    t.integer  "response_count",     default: 0
    t.integer  "answer_index_total", default: 0
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.index ["category_id"], name: "index_school_categories_on_category_id", using: :btree
    t.index ["school_id"], name: "index_school_categories_on_school_id", using: :btree
  end

  create_table "schools", force: :cascade do |t|
    t.string   "name"
    t.integer  "district_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.text     "description"
    t.string   "slug"
    t.index ["slug"], name: "index_schools_on_slug", unique: true, using: :btree
  end

  create_table "students", force: :cascade do |t|
    t.string   "name"
    t.string   "teacher"
    t.date     "birthdate"
    t.string   "gender"
    t.string   "age"
    t.string   "ethnicity"
    t.integer  "recipient_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "user_schools", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "school_id"
    t.integer  "district_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "recipient_lists", "schools"
  add_foreign_key "schedules", "schools"
  add_foreign_key "school_categories", "categories"
  add_foreign_key "school_categories", "schools"
end
