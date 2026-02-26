# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_26_020508) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "cnpj", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_categories_on_account_id"
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.bigint "request_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["account_id"], name: "index_comments_on_account_id"
    t.index ["request_id"], name: "index_comments_on_request_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "requests", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "decided_at"
    t.text "description"
    t.text "rejected_reason"
    t.string "status", default: "draft", null: false
    t.datetime "submitted_at"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["account_id"], name: "index_requests_on_account_id"
    t.index ["category_id"], name: "index_requests_on_category_id"
    t.index ["user_id"], name: "index_requests_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "role", default: "viewer", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_users_on_account_id"
  end

  add_foreign_key "categories", "accounts"
  add_foreign_key "comments", "accounts"
  add_foreign_key "comments", "requests"
  add_foreign_key "comments", "users"
  add_foreign_key "requests", "accounts"
  add_foreign_key "requests", "categories"
  add_foreign_key "requests", "users"
  add_foreign_key "users", "accounts"
end
