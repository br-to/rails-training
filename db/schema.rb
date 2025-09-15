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

ActiveRecord::Schema[7.2].define(version: 2025_09_15_140312) do
  create_table "accounts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "balance", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_accounts_on_user_id", unique: true
    t.check_constraint "`balance` >= 0", name: "balance_non_negative"
  end

  create_table "api_tokens", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token_digest"
    t.datetime "revoked_at"
    t.datetime "last_used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_api_tokens_on_user_id"
  end

  create_table "articles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title", null: false
    t.text "body", null: false
    t.boolean "published", default: false, null: false
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "comments_count", default: 0, null: false
    t.index ["published", "published_at"], name: "index_articles_on_published_and_published_at"
    t.index ["title"], name: "index_articles_on_title", unique: true
  end

  create_table "comments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "article_id", null: false
    t.text "body"
    t.string "author"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id"], name: "index_comments_on_article_id"
  end

  create_table "transfers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "from_account_id", null: false
    t.bigint "to_account_id", null: false
    t.integer "amount", null: false
    t.string "idempotency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_account_id"], name: "fk_rails_3b260aee3c"
    t.index ["idempotency_key"], name: "index_transfers_on_idempotency_key", unique: true
    t.index ["to_account_id"], name: "fk_rails_0ed16a9709"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["name"], name: "index_users_on_name"
  end

  add_foreign_key "accounts", "users"
  add_foreign_key "api_tokens", "users"
  add_foreign_key "comments", "articles"
  add_foreign_key "transfers", "accounts", column: "from_account_id"
  add_foreign_key "transfers", "accounts", column: "to_account_id"
end
