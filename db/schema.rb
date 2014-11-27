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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20141127160137) do

  create_table "all_tags", :force => true do |t|
    t.string   "name"
    t.text     "similar"
    t.integer  "weight",     :default => 0
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "app_category_feature_images", :force => true do |t|
    t.integer "category_id"
    t.integer "main_color_id"
    t.string  "feature_image"
  end

  create_table "app_infos", :force => true do |t|
    t.string   "code"
    t.string   "version"
    t.string   "ios_version"
    t.string   "ios_app_url"
    t.text     "feature"
    t.string   "download_url"
    t.string   "app_name"
    t.boolean  "active"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "ios_id"
  end

  create_table "apps", :force => true do |t|
    t.string   "back_url"
    t.string   "click_url"
    t.string   "dev_name"
    t.string   "desc"
    t.string   "panel_small"
    t.string   "app_type"
    t.string   "name"
    t.string   "panel_large"
    t.string   "icon_url"
    t.string   "bannel_small"
    t.string   "banner_large"
    t.string   "show_cb_url"
    t.string   "banner_middle"
    t.integer  "source_type"
    t.boolean  "on"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "url_scheme"
    t.string   "ios_id"
    t.integer  "weight"
  end

  add_index "apps", ["weight"], :name => "index_apps_on_weight"

  create_table "areas", :force => true do |t|
    t.string   "name"
    t.string   "city"
    t.integer  "city_id"
    t.string   "t"
    t.string   "jindu"
    t.string   "weidu"
    t.string   "parent"
    t.integer  "parent_dp_id"
    t.integer  "dp_id"
    t.boolean  "on"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "bd_id"
    t.string   "pinyin"
  end

  add_index "areas", ["city_id", "t", "on"], :name => "index_areas_on_city_id_and_t_and_on"
  add_index "areas", ["city_id", "t"], :name => "index_areas_on_city_id_and_t"
  add_index "areas", ["dp_id"], :name => "index_areas_on_dp_id"
  add_index "areas", ["name"], :name => "index_areas_on_name"
  add_index "areas", ["parent_dp_id"], :name => "index_areas_on_parent_dp_id"
  add_index "areas", ["pinyin"], :name => "index_areas_on_pinyin"

  create_table "ask_for_dapeis", :force => true do |t|
    t.integer  "user_id"
    t.integer  "matter_id"
    t.integer  "level"
    t.integer  "dapei_id"
    t.integer  "dapeis_count"
    t.integer  "status"
    t.integer  "likes_count"
    t.integer  "comments_count"
    t.integer  "dispose_count"
    t.integer  "reward"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.text     "title"
    t.integer  "answers_count"
    t.string   "digest"
    t.string   "url"
    t.string   "tag"
  end

  add_index "ask_for_dapeis", ["digest"], :name => "index_ask_for_dapeis_on_digest"
  add_index "ask_for_dapeis", ["level"], :name => "index_ask_for_dapeis_on_level"
  add_index "ask_for_dapeis", ["matter_id"], :name => "index_ask_for_dapeis_on_matter_id"
  add_index "ask_for_dapeis", ["reward"], :name => "index_ask_for_dapeis_on_reward"
  add_index "ask_for_dapeis", ["status"], :name => "index_ask_for_dapeis_on_status"
  add_index "ask_for_dapeis", ["user_id"], :name => "index_ask_for_dapeis_on_user_id"

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "access_token"
    t.integer  "expires_at"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "authentications", ["user_id"], :name => "index_authentications_on_user_id"

  create_table "brand_tags", :force => true do |t|
    t.string   "name"
    t.integer  "thing_image_id"
    t.integer  "type_id"
    t.boolean  "on"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "brands", :force => true do |t|
    t.string   "name"
    t.string   "e_name"
    t.text     "des"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "skus_count",       :default => 0
    t.integer  "shops_count"
    t.string   "properties"
    t.string   "property_keys"
    t.integer  "likes_count"
    t.integer  "comments_count"
    t.integer  "dispose_count"
    t.string   "url"
    t.integer  "type"
    t.integer  "level"
    t.integer  "rating"
    t.string   "address"
    t.string   "products"
    t.string   "tags"
    t.string   "phone_number"
    t.integer  "avatar_id"
    t.string   "homepage"
    t.string   "weibo"
    t.string   "tmall"
    t.string   "weixin"
    t.string   "crawled_source"
    t.string   "introduction"
    t.string   "price_level"
    t.text     "brand_intro"
    t.string   "c_name"
    t.integer  "low_price"
    t.integer  "high_price"
    t.integer  "shop_photo_id"
    t.integer  "brand_photo_id"
    t.string   "wide_avatar_url"
    t.integer  "category_id"
    t.string   "white_avatar_url"
    t.string   "black_avatar_url"
    t.string   "domain"
    t.string   "display_name"
    t.string   "currency"
    t.integer  "priority",         :default => 0
    t.integer  "brand_type"
    t.integer  "brand_type_1"
    t.integer  "brand_type_2"
    t.integer  "brand_type_3"
    t.integer  "img_quality"
    t.datetime "last_updated"
    t.string   "campaign_img_url"
    t.integer  "dapei_count"
  end

  add_index "brands", ["c_name"], :name => "index_brands_on_c_name"
  add_index "brands", ["category_id"], :name => "index_brands_on_category_id"
  add_index "brands", ["e_name"], :name => "index_brands_on_e_name"
  add_index "brands", ["level"], :name => "index_brands_on_level"
  add_index "brands", ["priority"], :name => "index_brands_on_priority"
  add_index "brands", ["rating"], :name => "index_brands_on_rating"
  add_index "brands", ["type"], :name => "index_brands_on_type"
  add_index "brands", ["url"], :name => "index_brands_on_url"

  create_table "carts", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "carts", ["user_id"], :name => "index_carts_on_user_id"

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.integer  "items_count"
    t.string   "abb"
    t.integer  "thing_img_id",      :limit => 8
    t.boolean  "is_active"
    t.integer  "weight"
    t.string   "synonym"
    t.string   "image_thing"
    t.string   "app_icon_image",                 :default => ""
    t.text     "desc"
    t.integer  "is_active_for_app",              :default => 0
    t.string   "thumb_url",                      :default => ""
    t.float    "min_price"
    t.float    "max_price"
  end

  add_index "categories", ["abb"], :name => "index_categories_on_abb"
  add_index "categories", ["parent_id"], :name => "index_categories_on_parent_id"

  create_table "cell_types", :force => true do |t|
    t.integer "type_num"
    t.string  "mark"
    t.integer "width"
    t.integer "height"
    t.integer "typeset_type_id"
    t.integer "data_row"
    t.integer "data_col"
    t.integer "data_sizex"
    t.integer "data_sizey"
  end

  create_table "colors", :force => true do |t|
    t.string  "color_name"
    t.string  "color_slug"
    t.integer "color_r"
    t.integer "color_g"
    t.integer "color_b"
    t.string  "color_rgb"
    t.string  "color_16"
  end

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50, :default => ""
    t.text     "comment"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.integer  "tuid"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type", "commentable_id"], :name => "index_comments_on_commentable_type_and_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "conversations", :force => true do |t|
    t.string   "subject",    :default => ""
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "crawler_templates", :force => true do |t|
    t.string   "t"
    t.string   "brand_name"
    t.integer  "brand_id"
    t.string   "template"
    t.string   "pattern"
    t.integer  "skus_count"
    t.boolean  "status"
    t.integer  "last_skus_count"
    t.string   "source"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "mall_id"
  end

  add_index "crawler_templates", ["brand_id"], :name => "index_crawler_templates_on_brand_id"
  add_index "crawler_templates", ["mall_id"], :name => "index_crawler_templates_on_mall_id"

  create_table "currency_rates", :force => true do |t|
    t.string   "name"
    t.string   "currency"
    t.float    "rate"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "dapei_infos", :force => true do |t|
    t.integer  "user_id"
    t.integer  "did"
    t.integer  "basedon_tid"
    t.string   "title"
    t.text     "description"
    t.integer  "category_id"
    t.string   "post_share"
    t.string   "spec_uuid"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "dapei_id"
    t.integer  "dapei_template_id"
    t.string   "width"
    t.string   "height"
    t.integer  "is_show",           :default => 1
    t.string   "tags"
    t.integer  "color_one_id"
    t.integer  "color_two_id"
    t.integer  "color_three_id"
    t.date     "start_date"
    t.string   "end_date_date"
    t.date     "end_date"
    t.boolean  "tagged"
    t.integer  "dapei_tags_id"
    t.string   "by"
    t.integer  "is_star",           :default => 0
    t.integer  "original_id"
    t.text     "comment"
    t.datetime "start_time"
    t.integer  "start_date_hour"
    t.string   "dir"
  end

  add_index "dapei_infos", ["category_id"], :name => "index_dapei_infos_on_category_id"
  add_index "dapei_infos", ["dapei_id"], :name => "index_dapei_infos_on_dapei_id"
  add_index "dapei_infos", ["dapei_tags_id"], :name => "index_dapei_infos_on_dapei_tags_id"
  add_index "dapei_infos", ["end_date"], :name => "index_dapei_infos_on_end_date"
  add_index "dapei_infos", ["spec_uuid"], :name => "index_dapei_infos_on_spec_uuid"
  add_index "dapei_infos", ["start_date"], :name => "index_dapei_infos_on_start_date"
  add_index "dapei_infos", ["user_id"], :name => "index_dapei_infos_on_user_id"

  create_table "dapei_item_infos", :force => true do |t|
    t.integer  "dapei_info_id"
    t.float    "x"
    t.float    "y"
    t.float    "w"
    t.float    "h"
    t.integer  "z"
    t.string   "item_type"
    t.string   "thing_id"
    t.integer  "sjb_item_id"
    t.integer  "sku_id"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "bkgd",          :default => 0
    t.string   "transform"
    t.text     "mask_spec"
    t.integer  "matter_id"
  end

  add_index "dapei_item_infos", ["dapei_info_id"], :name => "index_dapei_item_infos_on_dapei_info_id"
  add_index "dapei_item_infos", ["matter_id"], :name => "index_dapei_item_infos_on_matter_id"
  add_index "dapei_item_infos", ["sjb_item_id"], :name => "index_dapei_item_infos_on_sjb_item_id"
  add_index "dapei_item_infos", ["sku_id"], :name => "index_dapei_item_infos_on_sku_id"
  add_index "dapei_item_infos", ["thing_id"], :name => "index_dapei_item_infos_on_thing_id"

  create_table "dapei_responses", :force => true do |t|
    t.integer  "request_id"
    t.integer  "user_id"
    t.text     "response_text"
    t.string   "dapei_id"
    t.integer  "likes_count"
    t.integer  "comments_count"
    t.integer  "dispose_count"
    t.string   "response_image"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "digest"
  end

  add_index "dapei_responses", ["dapei_id"], :name => "index_dapei_responses_on_dapei_id"
  add_index "dapei_responses", ["digest"], :name => "index_dapei_responses_on_digest"
  add_index "dapei_responses", ["request_id"], :name => "index_dapei_responses_on_request_id"
  add_index "dapei_responses", ["user_id"], :name => "index_dapei_responses_on_user_id"

  create_table "dapei_tags", :force => true do |t|
    t.string   "name"
    t.integer  "tag_type"
    t.integer  "is_hot",      :default => 0
    t.string   "img_url"
    t.string   "avatar_url"
    t.string   "image_thing"
    t.string   "synonym"
    t.integer  "weight"
    t.integer  "parent_id"
    t.datetime "updated_at",                 :null => false
    t.datetime "created_at",                 :null => false
    t.integer  "user_id"
    t.text     "desc"
  end

  create_table "dapei_templates", :force => true do |t|
    t.string   "user_type"
    t.integer  "age"
    t.integer  "buddyicon"
    t.string   "state"
    t.integer  "tid"
    t.integer  "isOwner"
    t.string   "viewport"
    t.string   "spec_uuid"
    t.integer  "fills"
    t.string   "status_msg"
    t.string   "country"
    t.string   "occupation"
    t.string   "description"
    t.string   "user_name"
    t.string   "user_age"
    t.string   "user_state"
    t.integer  "user_id"
    t.string   "title"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "daren_applies", :force => true do |t|
    t.integer  "user_id"
    t.string   "mobile"
    t.string   "qq"
    t.string   "address"
    t.text     "reason"
    t.integer  "photo1_id"
    t.integer  "photo2_id"
    t.integer  "photo3_id"
    t.integer  "status"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "career"
    t.string   "contact"
    t.string   "phone"
    t.integer  "apply_type"
    t.integer  "production_type"
    t.string   "site"
    t.string   "matter_display_name"
    t.integer  "brand_id"
  end

  create_table "data_analyses", :force => true do |t|
    t.integer  "active_users",                :default => 0
    t.integer  "login_users",                 :default => 0
    t.integer  "new_users_count"
    t.integer  "qq_login_users",              :default => 0
    t.integer  "weibo_login_users",           :default => 0
    t.integer  "likes_count"
    t.integer  "comments_count"
    t.integer  "skus_count"
    t.integer  "dapeis_count"
    t.integer  "ask_counts"
    t.integer  "dapeis_view_count"
    t.integer  "skus_view_count"
    t.integer  "ask_view_count"
    t.date     "which_day"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.integer  "dapeis_likes_count",          :default => 0
    t.integer  "dapeis_comments_count",       :default => 0
    t.integer  "dapeis_like_users_count",     :default => 0
    t.integer  "dapeis_comment_users_count",  :default => 0
    t.integer  "dapeis_view_users_count",     :default => 0
    t.integer  "new_dapeis_users_count",      :default => 0
    t.integer  "ask_users_count",             :default => 0
    t.integer  "ask_answers_count",           :default => 0
    t.integer  "ask_ding_count",              :default => 0
    t.integer  "sku_like_users_count",        :default => 0
    t.integer  "sku_likes_count",             :default => 0
    t.integer  "sku_comments_count",          :default => 0
    t.integer  "sku_comment_users_count",     :default => 0
    t.integer  "collections_count",           :default => 0
    t.integer  "collection_view_count",       :default => 0
    t.integer  "collection_view_users_count", :default => 0
    t.integer  "collections_items_count",     :default => 0
    t.integer  "collection_like_count",       :default => 0
  end

  create_table "desc_tags", :force => true do |t|
    t.integer  "category_id"
    t.integer  "tag_id"
    t.string   "desc"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "is_show",     :default => 1
  end

  create_table "devices", :force => true do |t|
    t.integer  "user_id"
    t.string   "token"
    t.boolean  "enabled",    :default => true
    t.string   "platform"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.string   "udid"
  end

  add_index "devices", ["token"], :name => "index_devices_on_token"
  add_index "devices", ["udid"], :name => "index_devices_on_udid"
  add_index "devices", ["user_id"], :name => "index_devices_on_user_id"

  create_table "dfties", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "tel"
    t.string   "address"
    t.string   "ship_name"
    t.string   "ship_address"
    t.string   "invite_name1"
    t.string   "invite_name2"
    t.string   "invite_name3"
    t.string   "invite_name4"
    t.string   "invite_name5"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "dfties", ["name"], :name => "index_dfties_on_name"
  add_index "dfties", ["tel"], :name => "index_dfties_on_tel"
  add_index "dfties", ["user_id"], :name => "index_dfties_on_user_id"

  create_table "discounts", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "discountable_id"
    t.string   "discountable_type"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.string   "reason"
    t.integer  "dispose_count"
    t.integer  "likes_count",       :default => 0
    t.integer  "parent_id"
    t.boolean  "deleted"
    t.string   "docid"
    t.string   "from"
    t.string   "source"
    t.integer  "brand_discount_id"
    t.integer  "city_id"
    t.integer  "comments_count"
  end

  add_index "discounts", ["brand_discount_id"], :name => "index_discounts_on_brand_discount_id"
  add_index "discounts", ["created_at"], :name => "index_discounts_on_created_at"
  add_index "discounts", ["discountable_id"], :name => "index_discounts_on_discountable_id"
  add_index "discounts", ["discountable_type"], :name => "index_discounts_on_discountable_type"

  create_table "feedbacks", :force => true do |t|
    t.integer  "user_id"
    t.text     "content"
    t.string   "qq"
    t.string   "email"
    t.string   "telephone"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "five_ones", :force => true do |t|
    t.integer  "user_id"
    t.integer  "lucky_code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "flash_buy_coin_logs", :force => true do |t|
    t.integer  "user_id"
    t.string   "relatable_type"
    t.integer  "relatable_id"
    t.string   "coin_type"
    t.integer  "coin",           :default => 0
    t.boolean  "direction"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "flinks", :force => true do |t|
    t.string   "name"
    t.string   "link"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "flowers", :force => true do |t|
    t.integer  "user_id"
    t.integer  "lucky_code", :default => 0, :null => false
    t.integer  "is_lucky",   :default => 0, :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.string   "cookie"
  end

  add_index "flowers", ["created_at"], :name => "index_flowers_on_created_at"
  add_index "flowers", ["is_lucky"], :name => "index_flowers_on_is_lucky"
  add_index "flowers", ["user_id"], :name => "index_flowers_on_user_id"

  create_table "follows", :force => true do |t|
    t.integer  "followable_id",                      :null => false
    t.string   "followable_type",                    :null => false
    t.integer  "follower_id",                        :null => false
    t.string   "follower_type",                      :null => false
    t.boolean  "blocked",         :default => false, :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "follows", ["blocked"], :name => "index_follows_on_blocked"
  add_index "follows", ["followable_id", "followable_type", "follower_type", "blocked"], :name => "following_index"
  add_index "follows", ["followable_id", "followable_type"], :name => "fk_followables"
  add_index "follows", ["followable_id"], :name => "index_follows_on_followable_id"
  add_index "follows", ["followable_type"], :name => "index_follows_on_followable_type"
  add_index "follows", ["follower_id", "follower_type"], :name => "fk_follows"
  add_index "follows", ["follower_id"], :name => "index_follows_on_follower_id"
  add_index "follows", ["follower_type"], :name => "index_follows_on_follower_type"

  create_table "friend_apps", :force => true do |t|
    t.integer  "order_no",     :default => 0
    t.string   "app_name"
    t.text     "download_url"
    t.string   "icon_url"
    t.text     "description"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "click_count",  :default => 0
  end

  create_table "game_answers", :force => true do |t|
    t.string   "title"
    t.string   "img"
    t.integer  "viewable_id"
    t.string   "viewable_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "game_answers", ["viewable_id", "viewable_type"], :name => "index_game_answers_on_viewable_id_and_viewable_type"

  create_table "game_categories", :force => true do |t|
    t.text     "re_js"
    t.text     "re_css"
    t.text     "re_html"
    t.text     "meta"
    t.integer  "category_id"
    t.text     "html"
    t.string   "name"
    t.integer  "state"
    t.text     "js"
    t.text     "css"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "game_images", :force => true do |t|
    t.string   "title"
    t.integer  "viewable_id"
    t.string   "viewable_type"
    t.integer  "state"
    t.string   "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "game_images", ["viewable_id", "viewable_type"], :name => "index_game_images_on_viewable_id_and_viewable_type"

  create_table "game_materials", :force => true do |t|
    t.integer  "category_id"
    t.text     "html"
    t.string   "name"
    t.string   "slug"
    t.string   "wx_appid"
    t.string   "wx_tlimg"
    t.string   "wx_url"
    t.string   "wx_title"
    t.string   "wxdesc"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "game_materials", ["category_id"], :name => "index_game_materials_on_category_id"

  create_table "honours", :force => true do |t|
    t.integer  "user_id"
    t.integer  "honour_id"
    t.string   "name"
    t.string   "img"
    t.string   "url"
    t.boolean  "active"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "img_1"
    t.string   "small_image"
  end

  add_index "honours", ["honour_id"], :name => "index_honours_on_honour_id"
  add_index "honours", ["user_id", "honour_id", "active"], :name => "index_honours_on_user_id_and_honour_id_and_active"
  add_index "honours", ["user_id", "honour_id"], :name => "index_honours_on_user_id_and_honour_id"
  add_index "honours", ["user_id"], :name => "index_honours_on_user_id"

  create_table "inquiries", :force => true do |t|
    t.string   "name"
    t.string   "mobile"
    t.string   "city"
    t.string   "will"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "items", :force => true do |t|
    t.string   "title"
    t.string   "price"
    t.string   "discount"
    t.string   "display_area"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "shop_id"
    t.string   "url"
    t.integer  "category_id"
    t.integer  "comments_count",   :default => 0
    t.integer  "likes_count",      :default => 0
    t.integer  "dispose_count"
    t.integer  "user_id"
    t.integer  "brand_id"
    t.integer  "sku_id"
    t.integer  "level"
    t.string   "desc"
    t.string   "buy_url"
    t.boolean  "deleted"
    t.string   "publish"
    t.string   "from"
    t.integer  "city_id"
    t.string   "origin_price"
    t.integer  "off_percent"
    t.integer  "last_off_percent"
    t.string   "color"
    t.string   "tags"
    t.string   "type"
    t.string   "base_url"
    t.string   "cover_image"
    t.integer  "meta_tag_id"
    t.string   "index_info"
    t.integer  "dapei_info_flag"
    t.datetime "show_date"
  end

  add_index "items", ["brand_id", "sku_id"], :name => "index_items_on_brand_id_and_sku_id"
  add_index "items", ["brand_id"], :name => "index_items_on_brand_id"
  add_index "items", ["category_id"], :name => "index_items_on_category_id"
  add_index "items", ["created_at"], :name => "index_items_on_created_at"
  add_index "items", ["deleted"], :name => "index_items_on_deleted"
  add_index "items", ["level", "category_id"], :name => "index_items_on_level_and_category_id"
  add_index "items", ["level"], :name => "index_items_on_level"
  add_index "items", ["shop_id", "sku_id"], :name => "index_items_on_shop_id_and_sku_id"
  add_index "items", ["shop_id"], :name => "index_items_on_shop_id"
  add_index "items", ["sku_id"], :name => "index_items_on_sku_id"
  add_index "items", ["title"], :name => "index_items_on_title"
  add_index "items", ["url"], :name => "index_items_on_url"
  add_index "items", ["user_id", "level", "category_id", "deleted"], :name => "index_items_on_user_id_and_level_and_category_id_and_deleted"
  add_index "items", ["user_id"], :name => "index_items_on_user_id"

  create_table "join_lotteries", :force => true do |t|
    t.integer  "user_id"
    t.integer  "lottery_id"
    t.integer  "result"
    t.string   "qq"
    t.string   "tel"
    t.string   "name"
    t.string   "email"
    t.integer  "app_market_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "app_market_token"
  end

  add_index "join_lotteries", ["lottery_id"], :name => "index_join_lotteries_on_lottery_id"
  add_index "join_lotteries", ["user_id", "lottery_id"], :name => "index_join_lotteries_on_user_id_and_lottery_id"
  add_index "join_lotteries", ["user_id"], :name => "index_join_lotteries_on_user_id"

  create_table "labels", :force => true do |t|
    t.string   "name"
    t.integer  "weight"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "labels", ["name"], :name => "index_labels_on_name"

  create_table "like_count_users", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "like_count_users", ["created_at"], :name => "index_like_count_users_on_created_at"
  add_index "like_count_users", ["user_id"], :name => "index_like_count_users_on_user_id"

  create_table "likes", :force => true do |t|
    t.boolean  "positive",                  :default => true
    t.integer  "target_id"
    t.integer  "user_id"
    t.string   "target_type", :limit => 60,                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "likes", ["target_id"], :name => "index_likes_on_target_id"
  add_index "likes", ["target_type", "target_id"], :name => "index_likes_on_target_type_and_target_id"
  add_index "likes", ["target_type"], :name => "index_likes_on_target_type"
  add_index "likes", ["user_id", "target_id", "target_type"], :name => "index_likes_on_user_id_and_target_id_and_target_type"
  add_index "likes", ["user_id"], :name => "index_likes_on_user_id"

  create_table "line_items", :force => true do |t|
    t.integer  "sku_id"
    t.string   "name"
    t.integer  "cart_id"
    t.integer  "order_id"
    t.integer  "quantity"
    t.integer  "state",                                    :default => 0
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.string   "image"
    t.decimal  "price",      :precision => 8, :scale => 2,                :null => false
    t.integer  "brand_id"
  end

  add_index "line_items", ["cart_id"], :name => "index_line_items_on_cart_id"
  add_index "line_items", ["order_id"], :name => "index_line_items_on_order_id"
  add_index "line_items", ["sku_id"], :name => "index_line_items_on_sku_id"

  create_table "lotteries", :force => true do |t|
    t.string   "title"
    t.text     "desc"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "award"
    t.integer  "type_id"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.string   "link"
    t.string   "img_url"
    t.integer  "wait",       :default => 1, :null => false
    t.boolean  "on"
  end

  create_table "main_colors", :force => true do |t|
    t.string "color_value"
    t.string "color_r"
    t.string "color_g"
    t.string "color_b"
  end

  create_table "malls", :force => true do |t|
    t.string   "name"
    t.string   "abs"
    t.string   "jindu"
    t.string   "weidu"
    t.string   "introduction"
    t.integer  "area_id"
    t.integer  "likes_count"
    t.integer  "dispose_count"
    t.integer  "shops_count"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "url"
    t.integer  "level"
    t.string   "weixin"
    t.string   "weibo"
    t.string   "homepage"
    t.integer  "avatar_id"
    t.string   "address"
    t.string   "phone_number"
    t.string   "open_hours"
    t.integer  "items_count"
    t.string   "tags"
    t.integer  "city_id"
    t.string   "pattern"
  end

  add_index "malls", ["name"], :name => "index_malls_on_name"

  create_table "mask_specs", :force => true do |t|
    t.integer "template_item_id"
    t.string  "x"
    t.string  "y"
    t.integer "w"
    t.integer "h"
    t.integer "matter_id"
    t.string  "template_spec"
    t.text    "mask_spec"
    t.string  "mask_spec_image_name"
  end

  add_index "mask_specs", ["matter_id", "template_spec"], :name => "index_mask_specs_on_matter_id_and_template_spec"
  add_index "mask_specs", ["matter_id"], :name => "index_mask_specs_on_matter_id"
  add_index "mask_specs", ["template_spec"], :name => "index_mask_specs_on_template_spec"

  create_table "matter_infos", :force => true do |t|
    t.integer  "matter_id"
    t.string   "w"
    t.string   "paid_url"
    t.string   "thing_id"
    t.string   "masking_policy"
    t.string   "brand_id"
    t.string   "oh"
    t.string   "h"
    t.string   "displayurl"
    t.string   "url"
    t.string   "object_id"
    t.string   "host_id"
    t.string   "object_class"
    t.string   "seo_title"
    t.string   "title"
    t.string   "ow"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.string   "price"
    t.string   "display_price"
    t.string   "orig_price"
    t.string   "allow_colorizable"
    t.string   "allow_opacity"
    t.integer  "taobao_id",         :limit => 8
  end

  create_table "matter_tags", :force => true do |t|
    t.string   "tag_name"
    t.string   "tag_slug"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "matters", :force => true do |t|
    t.integer  "user_id"
    t.integer  "source_type"
    t.integer  "rule_category_id"
    t.integer  "color_one_id"
    t.integer  "color_two_id"
    t.integer  "color_three_id"
    t.string   "local_photo_name"
    t.string   "local_photo_path"
    t.string   "local_cut_photo_name"
    t.string   "local_cut_photo_path"
    t.string   "remote_photo_path"
    t.string   "remote_photo_name"
    t.integer  "sjb_photo_id"
    t.string   "height"
    t.string   "width"
    t.integer  "is_cut"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.string   "image_name"
    t.integer  "sjb_item_id"
    t.integer  "sku_id"
    t.string   "tags"
    t.integer  "likes_count"
    t.integer  "level"
    t.integer  "dapeis_count"
    t.integer  "brand_id"
    t.integer  "spider_id"
    t.string   "title"
    t.text     "desc"
    t.integer  "price"
    t.integer  "sub_category_id"
    t.string   "link"
    t.integer  "comments_count"
    t.integer  "dispose_count"
    t.string   "head"
  end

  add_index "matters", ["brand_id"], :name => "index_matters_on_brand_id"
  add_index "matters", ["color_one_id"], :name => "index_matters_on_color_one_id"
  add_index "matters", ["color_three_id"], :name => "index_matters_on_color_three_id"
  add_index "matters", ["color_two_id"], :name => "index_matters_on_color_two_id"
  add_index "matters", ["image_name"], :name => "index_matters_on_image_name"
  add_index "matters", ["level"], :name => "index_matters_on_level"
  add_index "matters", ["rule_category_id"], :name => "index_matters_on_rule_category_id"
  add_index "matters", ["sjb_photo_id"], :name => "index_matters_on_sjb_photo_id"
  add_index "matters", ["sku_id"], :name => "index_matters_on_sku_id"
  add_index "matters", ["spider_id"], :name => "index_matters_on_spider_id"
  add_index "matters", ["user_id"], :name => "index_matters_on_user_id"

  create_table "matters_users", :id => false, :force => true do |t|
    t.integer "matter_id"
    t.integer "user_id"
  end

  create_table "messages", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "accept_id"
    t.text     "content"
    t.string   "link_url"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "messages", ["accept_id"], :name => "index_messages_on_accept_id"
  add_index "messages", ["sender_id"], :name => "index_messages_on_sender_id"

  create_table "meta_tags", :force => true do |t|
    t.string   "tag"
    t.integer  "is_show"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "meta_image"
  end

  create_table "monitor_records", :force => true do |t|
    t.string   "controller"
    t.string   "action"
    t.string   "request_type"
    t.string   "request_params"
    t.string   "original_url"
    t.string   "remote_ip"
    t.string   "http_agent"
    t.integer  "user_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "monitor_records", ["controller", "action"], :name => "index_monitor_records_on_controller_and_action"
  add_index "monitor_records", ["created_at"], :name => "index_monitor_records_on_created_at"

  create_table "notifications", :force => true do |t|
    t.string   "type"
    t.text     "body"
    t.string   "subject",              :default => ""
    t.integer  "sender_id"
    t.string   "sender_type"
    t.integer  "conversation_id"
    t.boolean  "draft",                :default => false
    t.datetime "updated_at",                              :null => false
    t.datetime "created_at",                              :null => false
    t.integer  "notified_object_id"
    t.string   "notified_object_type"
    t.string   "notification_code"
    t.string   "attachment"
  end

  add_index "notifications", ["conversation_id"], :name => "index_notifications_on_conversation_id"
  add_index "notifications", ["notified_object_id"], :name => "index_notifications_on_notified_object_id"
  add_index "notifications", ["notified_object_type"], :name => "index_notifications_on_notified_object_type"
  add_index "notifications", ["sender_id"], :name => "index_notifications_on_sender_id"
  add_index "notifications", ["sender_type"], :name => "index_notifications_on_sender_type"
  add_index "notifications", ["type"], :name => "index_notifications_on_type"

  create_table "order_logs", :force => true do |t|
    t.integer  "order_id"
    t.integer  "user_id"
    t.string   "operator"
    t.string   "action"
    t.string   "detail"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "order_logs", ["order_id"], :name => "index_order_logs_on_order_id"

  create_table "order_marks", :force => true do |t|
    t.integer  "order_id"
    t.integer  "brand_id"
    t.integer  "user_id"
    t.text     "mark"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "orders", :force => true do |t|
    t.string   "number"
    t.integer  "user_id"
    t.text     "mark"
    t.decimal  "item_total",      :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "shipment_total",  :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "total",           :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "payment_total",   :precision => 10, :scale => 2, :default => 0.0
    t.integer  "ship_address_id"
    t.integer  "pay_type"
    t.string   "pay_number"
    t.integer  "state",                                          :default => 0
    t.datetime "created_at",                                                      :null => false
    t.datetime "updated_at",                                                      :null => false
    t.integer  "is_delete",                                      :default => 0
  end

  add_index "orders", ["ship_address_id"], :name => "index_orders_on_ship_address_id"
  add_index "orders", ["user_id"], :name => "index_orders_on_user_id"

  create_table "payments", :force => true do |t|
    t.integer  "order_id"
    t.integer  "user_id"
    t.string   "out_trade_no"
    t.integer  "coin_rate"
    t.decimal  "amount",            :precision => 10, :scale => 2, :default => 0.0, :null => false
    t.integer  "payment_method_id"
    t.integer  "state"
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.string   "trade_no"
  end

  add_index "payments", ["order_id"], :name => "index_payments_on_order_id"

  create_table "photos", :force => true do |t|
    t.integer  "author_id",                            :null => false
    t.boolean  "public",            :default => false, :null => false
    t.boolean  "pending",           :default => false, :null => false
    t.string   "target_type"
    t.integer  "target_id"
    t.text     "text"
    t.text     "remote_photo_path"
    t.string   "remote_photo_name"
    t.string   "random_string"
    t.string   "processed_image"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "unprocessed_image"
    t.integer  "height"
    t.integer  "width"
    t.boolean  "is_send",           :default => false
    t.boolean  "n2s"
    t.string   "digest"
    t.boolean  "dp"
  end

  add_index "photos", ["author_id"], :name => "index_photos_on_author_id"
  add_index "photos", ["created_at"], :name => "index_photos_on_created_at"
  add_index "photos", ["digest"], :name => "index_photos_on_digest"
  add_index "photos", ["is_send", "target_id", "target_type"], :name => "index_photos_on_is_send_and_target_id_and_target_type"
  add_index "photos", ["is_send"], :name => "index_photos_on_is_send"
  add_index "photos", ["target_id", "target_type"], :name => "index_photos_on_target_id_and_target_type"
  add_index "photos", ["target_id"], :name => "index_photos_on_target_id"
  add_index "photos", ["target_type"], :name => "index_photos_on_target_type"

  create_table "policies", :force => true do |t|
    t.string   "titlle"
    t.text     "desc"
    t.text     "condition"
    t.integer  "policy_type"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.text     "priority"
  end

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.integer  "user_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.string   "area"
    t.integer  "comments_count", :default => 0
    t.integer  "likes_count",    :default => 0
    t.integer  "categroy_id"
    t.integer  "category_id"
    t.string   "link"
    t.string   "thumb"
    t.integer  "is_show",        :default => 0,  :null => false
    t.string   "desc",           :default => ""
  end

  add_index "posts", ["category_id"], :name => "index_posts_on_category_id"
  add_index "posts", ["user_id"], :name => "index_posts_on_user_id"

  create_table "properties", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "properties_values", :force => true do |t|
    t.integer "sku_id"
    t.integer "property_id"
    t.string  "value"
  end

  create_table "property_property_values", :force => true do |t|
    t.integer "line_item_id"
    t.integer "property_id"
    t.integer "property_value_id"
  end

  add_index "property_property_values", ["line_item_id", "property_id", "property_value_id"], :name => "property_lpp", :unique => true
  add_index "property_property_values", ["line_item_id"], :name => "index_property_property_values_on_line_item_id"
  add_index "property_property_values", ["property_id"], :name => "index_property_property_values_on_property_id"

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 8
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

  create_table "receipts", :force => true do |t|
    t.integer  "receiver_id"
    t.string   "receiver_type"
    t.integer  "notification_id",                                  :null => false
    t.boolean  "is_read",                       :default => false
    t.boolean  "trashed",                       :default => false
    t.boolean  "deleted",                       :default => false
    t.string   "mailbox_type",    :limit => 25
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
  end

  add_index "receipts", ["deleted"], :name => "index_receipts_on_deleted"
  add_index "receipts", ["is_read"], :name => "index_receipts_on_is_read"
  add_index "receipts", ["mailbox_type"], :name => "index_receipts_on_mailbox_type"
  add_index "receipts", ["notification_id"], :name => "index_receipts_on_notification_id"
  add_index "receipts", ["receiver_id"], :name => "index_receipts_on_receiver_id"
  add_index "receipts", ["receiver_type"], :name => "index_receipts_on_receiver_type"
  add_index "receipts", ["trashed"], :name => "index_receipts_on_trashed"

  create_table "recommends", :force => true do |t|
    t.string   "recommended_type"
    t.integer  "recommended_id"
    t.string   "reason"
    t.integer  "point"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "name"
  end

  add_index "recommends", ["recommended_id"], :name => "index_recommends_on_recommended_id"
  add_index "recommends", ["recommended_type", "recommended_id"], :name => "index_recommends_on_recommended_type_and_recommended_id"
  add_index "recommends", ["recommended_type"], :name => "index_recommends_on_recommended_type"

  create_table "redirect_records", :force => true do |t|
    t.integer  "user_id",    :default => 0
    t.integer  "sku_id"
    t.string   "request_ip"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "rel_items", :force => true do |t|
    t.integer  "dapei_id"
    t.integer  "item_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "img_idx"
  end

  add_index "rel_items", ["dapei_id", "item_id"], :name => "index_rel_items_on_dapei_id_and_item_id"
  add_index "rel_items", ["dapei_id"], :name => "index_rel_items_on_dapei_id"
  add_index "rel_items", ["item_id", "dapei_id"], :name => "index_rel_items_on_item_id_and_dapei_id"
  add_index "rel_items", ["item_id"], :name => "index_rel_items_on_item_id"

  create_table "relations", :force => true do |t|
    t.integer  "item_id"
    t.string   "target_type"
    t.integer  "target_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "img_idx"
  end

  add_index "relations", ["item_id", "target_type", "target_id"], :name => "index_relations_on_item_id_and_target_type_and_target_id"
  add_index "relations", ["item_id"], :name => "index_relations_on_item_id"
  add_index "relations", ["target_type", "target_id"], :name => "index_relations_on_target_type_and_target_id"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "salers", :force => true do |t|
    t.integer  "user_id",          :null => false
    t.string   "access_token"
    t.string   "refresh_token"
    t.string   "taobao_user_nick"
    t.string   "taobao_user_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "set_cells", :force => true do |t|
    t.integer  "typeset_id"
    t.integer  "cell_type_id"
    t.string   "image"
    t.integer  "tag_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "set_cells", ["cell_type_id"], :name => "index_set_cells_on_cell_type_id"
  add_index "set_cells", ["tag_id"], :name => "index_set_cells_on_tag_id"
  add_index "set_cells", ["typeset_id"], :name => "index_set_cells_on_typeset_id"

  create_table "ship_addresses", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.string   "area",       :default => ""
    t.string   "address",    :default => ""
    t.string   "phone",      :default => ""
    t.integer  "is_default", :default => 0,  :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.string   "postcode"
  end

  add_index "ship_addresses", ["user_id"], :name => "index_ship_addresses_on_user_id"

  create_table "shipments", :force => true do |t|
    t.string   "tracking_url"
    t.string   "name"
    t.string   "number"
    t.decimal  "price",        :precision => 8, :scale => 2
    t.datetime "shipped_at"
    t.integer  "order_id"
    t.integer  "address_id"
    t.integer  "state"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.string   "shipname"
  end

  add_index "shipments", ["number"], :name => "index_shipments_on_number"
  add_index "shipments", ["order_id"], :name => "index_shipments_on_order_id"

  create_table "shipping_methods", :force => true do |t|
    t.string   "name"
    t.integer  "state",                                       :default => 0
    t.boolean  "default",                                     :default => false
    t.decimal  "price",        :precision => 10, :scale => 0
    t.string   "tracking_url"
    t.string   "admin_name"
    t.datetime "created_at",                                                     :null => false
    t.datetime "updated_at",                                                     :null => false
  end

  add_index "shipping_methods", ["default"], :name => "index_shipping_methods_on_default"
  add_index "shipping_methods", ["state", "default"], :name => "index_shipping_methods_on_state_and_default"

  create_table "shops", :force => true do |t|
    t.string   "name"
    t.string   "city"
    t.string   "district"
    t.string   "town"
    t.string   "street"
    t.string   "house_number"
    t.string   "jindu"
    t.string   "weidu"
    t.string   "address"
    t.integer  "rating"
    t.string   "open_hours"
    t.string   "product"
    t.string   "tags"
    t.string   "type"
    t.integer  "dp_id"
    t.integer  "area_id"
    t.integer  "level",                :default => 0
    t.integer  "likes_count",          :default => 0
    t.integer  "comments_count",       :default => 0
    t.integer  "dispose_count",        :default => 0
    t.integer  "user_id"
    t.integer  "items_count"
    t.string   "url"
    t.boolean  "activated",            :default => true
    t.boolean  "apply_authenticate",   :default => false
    t.boolean  "approve_authenticate", :default => false
    t.string   "phone_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "avatar_id"
    t.integer  "crawled"
    t.integer  "city_id"
    t.string   "mall"
    t.integer  "brand_id"
    t.string   "alias"
    t.string   "price_level"
    t.string   "brand_intro"
    t.string   "brand_name"
    t.integer  "mall_id"
    t.integer  "low_price"
    t.integer  "high_price"
    t.integer  "discounts_count",      :default => 0
    t.integer  "average_price"
    t.integer  "category_id"
    t.string   "bd_uid"
    t.integer  "priority"
    t.integer  "shop_type"
    t.string   "weibo"
    t.string   "weixin"
  end

  add_index "shops", ["apply_authenticate"], :name => "index_shops_on_apply_authenticate"
  add_index "shops", ["approve_authenticate"], :name => "index_shops_on_approve_authenticate"
  add_index "shops", ["area_id"], :name => "index_shops_on_area_id"
  add_index "shops", ["bd_uid"], :name => "index_shops_on_bd_uid"
  add_index "shops", ["brand_id"], :name => "index_shops_on_brand_id"
  add_index "shops", ["category_id"], :name => "index_shops_on_category_id"
  add_index "shops", ["city"], :name => "index_shops_on_city"
  add_index "shops", ["city_id"], :name => "index_shops_on_city_id"
  add_index "shops", ["created_at"], :name => "index_shops_on_created_at"
  add_index "shops", ["district"], :name => "index_shops_on_district"
  add_index "shops", ["level"], :name => "index_shops_on_level"
  add_index "shops", ["mall_id"], :name => "index_shops_on_mall_id"
  add_index "shops", ["name"], :name => "index_shops_on_name"
  add_index "shops", ["shop_type"], :name => "index_shops_on_shop_type"
  add_index "shops", ["street"], :name => "index_shops_on_street"
  add_index "shops", ["town"], :name => "index_shops_on_town"
  add_index "shops", ["url"], :name => "index_shops_on_url"
  add_index "shops", ["user_id"], :name => "index_shops_on_user_id"

  create_table "site_helps", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.string   "url"
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "url_action"
  end

  create_table "size_types", :force => true do |t|
    t.string "name"
  end

  create_table "sku_promotions", :force => true do |t|
    t.string   "promotion_id"
    t.string   "name"
    t.string   "item_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.float    "item_promo_price"
    t.integer  "sku_id"
  end

  add_index "sku_promotions", ["item_id", "promotion_id"], :name => "index_sku_promotions_on_item_id_and_promotion_id", :unique => true
  add_index "sku_promotions", ["sku_id"], :name => "index_sku_promotions_on_sku_id"

  create_table "sku_properties", :force => true do |t|
    t.integer  "sku_id"
    t.integer  "property_id"
    t.string   "value"
    t.integer  "count",           :default => 0
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.string   "color_image_url"
  end

  add_index "sku_properties", ["property_id"], :name => "index_sku_properties_on_property_id"
  add_index "sku_properties", ["sku_id"], :name => "index_sku_properties_on_sku_id"

  create_table "skus", :force => true do |t|
    t.string   "title"
    t.string   "price"
    t.integer  "brand_id"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.string   "properties"
    t.string   "property_keys"
    t.integer  "likes_count"
    t.integer  "comments_count"
    t.integer  "dispose_count"
    t.string   "url"
    t.integer  "category_id"
    t.string   "from"
    t.integer  "items_count"
    t.integer  "level"
    t.string   "desc"
    t.string   "docid"
    t.string   "buy_url"
    t.boolean  "deleted"
    t.string   "publish"
    t.string   "origin_price"
    t.integer  "store_count"
    t.integer  "sold_count"
    t.string   "tags"
    t.string   "pno"
    t.string   "sizes"
    t.text     "color"
    t.string   "color_url"
    t.integer  "off_percent"
    t.integer  "last_off_percent"
    t.string   "currency"
    t.string   "raw_imgs"
    t.string   "s_price"
    t.integer  "priority"
    t.integer  "color_one_id"
    t.integer  "color_two_id"
    t.integer  "color_three_id"
    t.string   "head"
    t.integer  "spider_id"
    t.integer  "sub_cat_id"
    t.boolean  "has_discount",     :default => false
    t.integer  "sub_category_id",  :default => 0,     :null => false
    t.float    "rate_score"
    t.integer  "is_checked",       :default => 0
    t.string   "origin_platform"
    t.integer  "view_count",       :default => 0
    t.boolean  "is_agent"
    t.boolean  "is_guide"
    t.float    "freight"
    t.float    "refer_price"
  end

  add_index "skus", ["brand_id"], :name => "index_skus_on_brand_id"
  add_index "skus", ["buy_url"], :name => "index_skus_on_buy_url"
  add_index "skus", ["category_id"], :name => "index_skus_on_category_id"
  add_index "skus", ["created_at"], :name => "index_skus_on_created_at"
  add_index "skus", ["docid"], :name => "index_skus_on_docid"
  add_index "skus", ["from"], :name => "index_skus_on_type"
  add_index "skus", ["level"], :name => "index_skus_on_level"
  add_index "skus", ["pno"], :name => "index_skus_on_pno"
  add_index "skus", ["spider_id"], :name => "index_skus_on_spider_id"
  add_index "skus", ["sub_category_id"], :name => "index_skus_on_sub_category_id"
  add_index "skus", ["url"], :name => "index_skus_on_url"

  create_table "skus_labels", :force => true do |t|
    t.integer "sku_id"
    t.integer "label_id"
  end

  create_table "sph_counter", :primary_key => "counter_id", :force => true do |t|
    t.integer "max_doc_id", :null => false
  end

  create_table "sph_timer_counter", :primary_key => "counter_id", :force => true do |t|
    t.integer  "max_doc_id", :null => false
    t.datetime "current"
  end

  create_table "spiders", :force => true do |t|
    t.string   "brand"
    t.text     "product_page"
    t.text     "next_page"
    t.text     "ptitle"
    t.text     "pprice"
    t.text     "pdesc"
    t.text     "pimgs"
    t.text     "others"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.text     "start_page"
    t.integer  "brand_id"
    t.text     "pcolor"
    t.text     "psize"
    t.text     "porigin_price"
    t.text     "pshow_img"
    t.text     "pcode"
    t.string   "pimg_attr"
    t.text     "pstore_count"
    t.text     "psold_count"
    t.integer  "hot"
    t.text     "phot"
    t.boolean  "stop"
    t.string   "img_rule"
    t.integer  "template_id"
    t.text     "start_page_4"
    t.text     "start_page_5"
    t.text     "start_page_6"
    t.text     "start_page_7"
    t.text     "start_page_8"
    t.text     "start_page_11"
    t.text     "start_page_12"
    t.text     "start_page_13"
    t.text     "start_page_14"
    t.text     "start_page_9"
    t.boolean  "is_template"
    t.integer  "pic_index"
    t.integer  "show_pic_index"
    t.integer  "shoe_pic_index"
    t.integer  "bag_pic_index"
    t.integer  "peishi_pic_index"
    t.string   "dp_img"
    t.integer  "update_period"
    t.datetime "last_updated"
    t.string   "dp_img_rule"
    t.string   "dp_img_attr"
    t.boolean  "available"
    t.text     "sold_out"
    t.string   "prate"
    t.string   "crop"
    t.string   "matter_crop"
    t.boolean  "is_agent"
    t.boolean  "is_guide"
    t.float    "freight"
    t.text     "start_page_10"
    t.boolean  "is_show_freight"
    t.float    "max_shoes_price"
    t.float    "max_clothes_price"
    t.float    "max_bags_price"
    t.string   "size_types"
    t.text     "now_price"
  end

  add_index "spiders", ["brand_id"], :name => "index_spiders_on_brand_id"

  create_table "streets", :force => true do |t|
    t.string   "name"
    t.integer  "area_id"
    t.string   "jindu"
    t.string   "weidu"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "introduction"
    t.integer  "likes_count"
    t.integer  "dispose_count"
    t.integer  "level"
    t.integer  "avatar_id"
    t.string   "address"
    t.string   "url"
    t.integer  "city_id"
  end

  add_index "streets", ["area_id"], :name => "index_streets_on_area_id"
  add_index "streets", ["name"], :name => "index_streets_on_name"

  create_table "synonyms", :force => true do |t|
    t.integer "category_id"
    t.string  "content"
  end

  create_table "tag_infos", :force => true do |t|
    t.integer  "photo_id"
    t.string   "tag_type"
    t.string   "name"
    t.string   "coord"
    t.boolean  "direction"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], :name => "taggings_idx", :unique => true
  add_index "taggings", ["tagger_id", "tagger_type"], :name => "index_taggings_on_tagger_id_and_tagger_type"

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.text    "desc"
    t.integer "is_show",        :default => 0, :null => false
    t.integer "weight"
    t.integer "taggings_count", :default => 0
    t.integer "type_id"
    t.string  "img"
    t.integer "parent_id"
    t.integer "show_index"
    t.boolean "active"
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true
  add_index "tags", ["type_id"], :name => "index_tags_on_type_id"

  create_table "template_items", :force => true do |t|
    t.integer  "dapei_template_id"
    t.integer  "template_item_type"
    t.string   "visibility"
    t.string   "a"
    t.string   "masking_policy"
    t.integer  "thing_id",           :limit => 8
    t.string   "oa"
    t.string   "state"
    t.string   "y"
    t.string   "url"
    t.integer  "old_thing_id"
    t.string   "sale_price"
    t.string   "imgurl"
    t.string   "title"
    t.string   "price"
    t.string   "item_type"
    t.string   "visible_ratio"
    t.integer  "z"
    t.integer  "ow"
    t.string   "w"
    t.integer  "brand_id"
    t.string   "x"
    t.string   "brand"
    t.integer  "opacity"
    t.string   "currency"
    t.string   "host_type"
    t.integer  "category_id"
    t.integer  "instock"
    t.string   "h"
    t.string   "oh"
    t.string   "displayurl"
    t.string   "createdby"
    t.string   "transform"
    t.integer  "feed"
    t.integer  "bkgd"
    t.string   "host"
    t.integer  "paid"
    t.string   "dropHint"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "mask_dirty"
    t.integer  "mask_id"
    t.string   "display_price"
  end

  add_index "template_items", ["dapei_template_id"], :name => "index_template_items_on_dapei_template_id"

  create_table "thumb_photos", :force => true do |t|
    t.text     "image"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tracks", :force => true do |t|
    t.integer  "user_id"
    t.string   "appid"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tshow_spiders", :force => true do |t|
    t.boolean  "stop"
    t.integer  "template_id"
    t.text     "start_page"
    t.boolean  "is_template"
    t.text     "images_start_page"
    t.string   "show_date"
    t.string   "city"
    t.string   "author"
    t.text     "content"
    t.integer  "brand_id"
    t.string   "season"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.text     "show_page"
    t.string   "img_attr"
    t.string   "img_rule"
    t.text     "others"
    t.datetime "last_updated"
  end

  create_table "tshows", :force => true do |t|
    t.date     "show_date"
    t.string   "city"
    t.string   "author"
    t.text     "content"
    t.integer  "brand_id"
    t.string   "season"
    t.integer  "tshow_spider_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "docid"
    t.string   "url"
  end

  add_index "tshows", ["docid"], :name => "index_tshows_on_docid", :unique => true

  create_table "typeset_types", :force => true do |t|
    t.string   "mark"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "typesets", :force => true do |t|
    t.string   "name"
    t.integer  "flag_type",       :default => 1
    t.integer  "is_active",       :default => 0
    t.integer  "order_no",        :default => 0, :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "typeset_type_id"
  end

  add_index "typesets", ["is_active"], :name => "index_typesets_on_is_active"
  add_index "typesets", ["order_no"], :name => "index_typesets_on_order_no"

  create_table "user_activities", :force => true do |t|
    t.integer  "user_id"
    t.string   "action"
    t.string   "object_type"
    t.string   "object"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "by"
    t.boolean  "recommended"
  end

  add_index "user_activities", ["action"], :name => "index_user_activities_on_action"
  add_index "user_activities", ["object_type", "object"], :name => "index_user_activities_report"
  add_index "user_activities", ["object_type"], :name => "index_user_activities_on_object_type"
  add_index "user_activities", ["user_id", "action"], :name => "index_user_activities_on_user_id_and_action"
  add_index "user_activities", ["user_id"], :name => "index_user_activities_on_user_id"

  create_table "user_behaviours", :force => true do |t|
    t.integer  "user_id"
    t.string   "request_url"
    t.string   "token"
    t.string   "ip_address"
    t.datetime "request_time"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "request_method"
  end

  add_index "user_behaviours", ["ip_address", "request_url", "request_time"], :name => "user_behaviours_ipurl", :unique => true
  add_index "user_behaviours", ["request_time"], :name => "index_user_behaviours_on_request_time"
  add_index "user_behaviours", ["request_url", "token", "request_time"], :name => "index_user_behaviours_request", :unique => true
  add_index "user_behaviours", ["user_id"], :name => "index_user_behaviours_on_user_id"

  create_table "user_devices", :force => true do |t|
    t.string   "appid"
    t.integer  "user_id"
    t.string   "baidu_uid"
    t.string   "channel_id"
    t.integer  "device_type"
    t.string   "token"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "version"
    t.string   "vendor"
    t.string   "identifier"
  end

  add_index "user_devices", ["baidu_uid"], :name => "index_user_devices_on_baidu_uid"
  add_index "user_devices", ["channel_id"], :name => "index_user_devices_on_channel_id"
  add_index "user_devices", ["device_type"], :name => "index_user_devices_on_device_type"
  add_index "user_devices", ["token"], :name => "index_user_devices_on_token"
  add_index "user_devices", ["user_id"], :name => "index_user_devices_on_user_id"

  create_table "user_exts", :force => true do |t|
    t.integer  "user_id"
    t.string   "wx_gz_id"
    t.string   "baidu_push_id"
    t.integer  "cj_num_1"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "weixin_id"
  end

  create_table "user_locations", :force => true do |t|
    t.integer  "user_id"
    t.string   "jindu"
    t.string   "weidu"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "city_id"
  end

  create_table "userinfos", :force => true do |t|
    t.integer  "user_id",                        :null => false
    t.integer  "followers_count", :default => 0
    t.integer  "following_count", :default => 0
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "shangou_id"
    t.string   "shangou_token"
  end

  add_index "userinfos", ["user_id"], :name => "index_userinfos_on_user_id", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",   :null => false
    t.string   "encrypted_password",     :default => "",   :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.string   "name"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "is_girl",                :default => "1"
    t.datetime "birthday"
    t.integer  "age"
    t.string   "city"
    t.string   "district"
    t.boolean  "getting_started",        :default => true
    t.string   "avatar"
    t.string   "nickname"
    t.boolean  "real"
    t.string   "url"
    t.integer  "posts_count",            :default => 0
    t.string   "desc"
    t.string   "preurl"
    t.string   "profile_img_url"
    t.string   "authentication_token"
    t.integer  "comments_count",         :default => 0
    t.string   "likes_count",            :default => "0"
    t.integer  "city_id"
    t.integer  "dapei_score"
    t.integer  "bg_photo_id"
    t.string   "qq"
    t.integer  "level"
    t.integer  "dapeis_count",           :default => 0
    t.string   "mobile"
    t.string   "xingzuo"
    t.integer  "coin",                   :default => 0
    t.integer  "mobile_state"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["comments_count"], :name => "index_users_on_comments_count"
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["created_at"], :name => "index_users_on_created_at"
  add_index "users", ["current_sign_in_at"], :name => "index_users_on_current_sign_in_at"
  add_index "users", ["dapei_score"], :name => "index_users_on_dapei_score"
  add_index "users", ["dapeis_count"], :name => "index_users_on_dapeis_count"
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["level"], :name => "index_users_on_level"
  add_index "users", ["mobile"], :name => "index_users_on_mobile"
  add_index "users", ["name"], :name => "index_users_on_name"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["url"], :name => "index_users_on_url"

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

  create_table "winners", :force => true do |t|
    t.integer  "user_id"
    t.string   "real_name"
    t.string   "address"
    t.string   "phone"
    t.integer  "win_what"
    t.string   "mark"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "postcode"
  end

  add_foreign_key "notifications", "conversations", :name => "notifications_on_conversation_id"

  add_foreign_key "receipts", "notifications", :name => "receipts_on_notification_id"

end
