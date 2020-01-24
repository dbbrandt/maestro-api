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

ActiveRecord::Schema.define(version: 20200111001058) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contents", force: :cascade do |t|
    t.string "title"
    t.string "content_type"
    t.string "description"
    t.string "stimulus_url"
    t.string "copy"
    t.float "score"
    t.string "descriptor"
    t.bigint "interaction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["interaction_id"], name: "index_contents_on_interaction_id"
  end

  create_table "goals", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.string "instructions"
    t.string "image_url"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_goals_on_user_id"
  end

  create_table "import_files", force: :cascade do |t|
    t.string "title"
    t.string "json_data"
    t.bigint "goal_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["goal_id"], name: "index_import_files_on_goal_id"
  end

  create_table "import_rows", force: :cascade do |t|
    t.string "title"
    t.string "json_data"
    t.bigint "import_file_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["import_file_id"], name: "index_import_rows_on_import_file_id"
  end

  create_table "interactions", force: :cascade do |t|
    t.string "title"
    t.string "answer_type"
    t.boolean "active", default: true
    t.bigint "goal_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "import_row_id"
    t.index ["goal_id"], name: "index_interactions_on_goal_id"
    t.index ["import_row_id"], name: "index_interactions_on_import_row_id"
  end

  create_table "round_responses", id: :bigint, default: -> { "nextval('responses_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "answer"
    t.float "score"
    t.boolean "is_correct"
    t.boolean "review_is_correct"
    t.string "descriptor"
    t.bigint "round_id"
    t.bigint "interaction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["interaction_id"], name: "index_responses_on_interaction_id"
    t.index ["round_id"], name: "index_responses_on_round_id"
  end

  create_table "rounds", force: :cascade do |t|
    t.string "notes"
    t.bigint "goal_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["goal_id"], name: "index_rounds_on_goal_id"
    t.index ["user_id"], name: "index_rounds_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "name"
    t.string "avatar_url"
    t.boolean "admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "contents", "interactions"
  add_foreign_key "goals", "users"
  add_foreign_key "import_files", "goals"
  add_foreign_key "import_rows", "import_files"
  add_foreign_key "interactions", "goals"
  add_foreign_key "interactions", "import_rows"
  add_foreign_key "round_responses", "interactions"
  add_foreign_key "round_responses", "rounds"
  add_foreign_key "rounds", "goals"
  add_foreign_key "rounds", "users"
end
