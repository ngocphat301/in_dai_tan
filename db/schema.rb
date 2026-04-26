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

ActiveRecord::Schema[8.1].define(version: 2026_04_17_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"
  enable_extension "unaccent"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "ad_leads", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "phone", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_ad_leads_on_created_at"
  end

  create_table "blog_posts", force: :cascade do |t|
    t.string "category", default: "news", null: false
    t.datetime "created_at", null: false
    t.text "excerpt"
    t.text "meta_description"
    t.string "meta_title"
    t.datetime "published_at"
    t.string "slug", null: false
    t.string "status", default: "hidden", null: false
    t.string "tags", default: [], null: false, array: true
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["category"], name: "index_blog_posts_on_category"
    t.index ["slug"], name: "index_blog_posts_on_slug", unique: true
    t.index ["status"], name: "index_blog_posts_on_status"
    t.index ["title"], name: "index_blog_posts_on_title_trgm", opclass: :gin_trgm_ops, using: :gin
    t.index ["user_id"], name: "index_blog_posts_on_user_id"
  end

  create_table "images", force: :cascade do |t|
    t.string "caption"
    t.datetime "created_at", null: false
    t.string "kind", default: "gallery", null: false
    t.integer "position", default: 0, null: false
    t.bigint "product_id", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_images_on_product_id"
  end

  create_table "product_categories", force: :cascade do |t|
    t.bigint "blog_post_id"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["blog_post_id"], name: "index_product_categories_on_blog_post_id", unique: true
    t.index ["slug"], name: "index_product_categories_on_slug", unique: true
  end

  create_table "products", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.integer "original_price_vnd", default: 0, null: false
    t.bigint "product_category_id", null: false
    t.datetime "promo_ends_at"
    t.datetime "promo_starts_at"
    t.boolean "published", default: true, null: false
    t.integer "sale_price_vnd", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_products_on_name_trgm", opclass: :gin_trgm_ops, using: :gin
    t.index ["product_category_id"], name: "index_products_on_product_category_id"
  end

  create_table "quote_requests", force: :cascade do |t|
    t.bigint "assigned_to_id"
    t.bigint "blog_post_id"
    t.text "body"
    t.datetime "created_at", null: false
    t.string "customer_name", null: false
    t.string "phone", null: false
    t.bigint "product_category_id"
    t.bigint "product_id"
    t.string "purchase_status", default: "pending", null: false
    t.string "request_type", default: "product", null: false
    t.boolean "staff_received", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_to_id"], name: "index_quote_requests_on_assigned_to_id"
    t.index ["blog_post_id"], name: "index_quote_requests_on_blog_post_id"
    t.index ["created_at"], name: "index_quote_requests_on_created_at"
    t.index ["product_category_id"], name: "index_quote_requests_on_product_category_id"
    t.index ["product_id"], name: "index_quote_requests_on_product_id"
    t.index ["purchase_status"], name: "index_quote_requests_on_purchase_status"
    t.index ["request_type"], name: "index_quote_requests_on_request_type"
    t.index ["staff_received"], name: "index_quote_requests_on_staff_received"
  end

  create_table "site_images", force: :cascade do |t|
    t.string "alt_text"
    t.string "category", default: "banner", null: false
    t.datetime "created_at", null: false
    t.string "link_url"
    t.string "popup_title"
    t.integer "position", default: 0, null: false
    t.boolean "published", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["category", "position"], name: "index_site_images_on_category_and_position"
    t.index ["category"], name: "index_site_images_on_category"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role", default: "member", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "blog_posts", "users"
  add_foreign_key "images", "products"
  add_foreign_key "product_categories", "blog_posts", on_delete: :nullify
  add_foreign_key "products", "product_categories"
  add_foreign_key "quote_requests", "blog_posts"
  add_foreign_key "quote_requests", "product_categories"
  add_foreign_key "quote_requests", "products"
  add_foreign_key "quote_requests", "users", column: "assigned_to_id"
end
