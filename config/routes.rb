# -*- encoding : utf-8 -*-
require 'sidekiq/web'
Shangjieba::Application.routes.draw do
  mount SjbApi => '/'
  mount Sidekiq::Web => '/sidekiq'
  resources :tracks


  namespace :shangou do
    resources :users
  end

  resources :dfties

  resources :honours

  resources :user_activities

  resources :dapei_responses

  resources :dapei_responses do
    resources :comments, :only => [:index, :create, :destroy], :name_prefix => "dapei_response_"
  end

  resources :ask_for_dapeis do

    member do
      get :view_show
    end

    member do
      get :stick
      get :unstick
    end

  end

  get 'matters/:id/view_show' => 'matters#view_show'
  get 'matters/new_matter' => 'matters#new_matter'


  get 'dapei_responses/:id/liked_users' => 'dapei_responses#like_users', :as => "dapei_response_like_users"

  get 'ask_for_dapeis/:request_id/answers' => "dapei_responses#index"

  get 'dapei_requests/main' => "ask_for_dapeis#main"

  namespace :m do
    root :to => "welcome#index"
  end

  get "welcome/index"

  get "welcome/m"

  get "/welcome/friend_apps" => "welcome#friend_apps"
  get "/welcome/friend_weixins" => "welcome#friend_weixins"
  post "/welcome/go_download" => "welcome#go_download"

  get "/users/:id/grow_info" => "users#info"

  namespace :monitor do
    root to: "welcome#index"
    get "welcome/home" => "welcome#home"
    get "welcome/expire_index" => "welcome#expire_index"
  end


  resources :notify, only: [] do
    collection do
      post :alipay
      post :wxpay
    end
  end

  namespace :manage do
    root to: "home#index"
    resources :friend_apps
    
    resources :synonyms
    resources :posts do
      member do
        get :photo
        post :photo_create
      end
    end

    post "/posts/:id" => "posts#update"
    resources :tags do
      member do
        get :get_desc
      end
    end

    resources :all_tags
    get '/dapeis/queue' => "dapeis#queue"
    get '/collections' => "dapeis#collections"
    get '/selfies' => "dapeis#selfies"
    get '/dapeis/:id/new_comment' => "dapeis#new_comment"
    put '/selfy/:id', to: 'dapeis#selfy_update', as: :selfy
    resources :collections do
      member do
        post :cover_photo # 封面图
      end
      resources :comments, :only => [:index, :create, :destroy], :name_prefix => "item_"
    end

    resources :selfies ,:only =>[:new,:create]
    # resources :dapeis
    resources :dapeis do
      collection do
        get 'all'
      end

      member do
        post 'recommend_star'
        post 'unrecommend_star'
      end
    end

    put "categories/set_app_photo" => "categories#set_app_photo"

    resources :categories do
      collection do
        get :for_select
        get :ajax_select_change
      end

      member do
        get :feature
        post :feature_create
      end
    end
    resources :matters do
      collection do
        get :recommends
        get :brands
        get :tags
        post :recommended
      end
    end

    get 'matters/:id/koutu' => "matters#koutu"
    get 'user_behaviours/:user_id' => "user_behaviours#index"
    get 'user_behaviours/xml_index/:user_token' => "user_behaviours#xml_index"
    resources :user_behaviours
    resources :matter_tags
    resources :meta_tags

    resources :dapei_tags do
      member do
        post :upload
      end
    end

    resources :apps
    resources :photos, only: :destroy
    resources :flinks
    resources :crawler_templates do
      collection do
        get "search_brands"
        get "search_malls"
      end
    end
    resources :users, except: :new do
      member do
        get :set_black
        get :set_v
      end
      resources :messages
    end

    resources :malls
    resources :discounts
    resources :spiders, except: :new do
      member do
        get :start_crawl
        get :start_soldout
        get :update_state
      end
      resources :spider_pages
    end
    post '/spiders/:spider_id/spider_pages' => 'spider_pages#create', :as => 'spider_spider_pages_index'


    resources :tshow_spiders, except: :new do
      member do
        get :start_crawl
      end
    end
    resources :brand_tags
    resources :brands do
      resources :spiders, only: :new
      resources :tshow_spiders, only: :new
      member do
        get :spiders
        post :upload
      end
    end

    resources :shops do
      member do
        get :discounts
      end
    end

    resources :feedbacks
    resources :lotteries

    get "update_category_photo/:category_id/:matter_id" => "categories#set_photo", :as => "update_category_photo"
  end


  namespace :service do
    get "dapei/get_color" => "dapei#get_color"
    get "dapei/template_cut" => "dapei#template_cut"
    get "dapei/cut_templates" => "dapei#cut_templates"
  end

  resources :daren_applies do
    collection do
      get "about_daren"
      get "user_help"
      get "daren_info"
      get "medal_info"
    end
  end  

  scope "sjb" do
    resources :relations

    resources :labels

    resources :policies

    resources :user_devices

    resources :user_exts do
      collection do
        get :new_create
      end
    end

    get "user_exts/new_create/fr/android" => "user_exts#new_create"
    get "user_exts/create_result" => "user_exts#create_result"


    resources :lotteries

    resources :join_lotteries
    get "join_lottery/status" => "join_lotteries#status"
    get "lottery/current" => "lotteries#current"

    get "cj" => "user_exts#cj"
    get "reg" => "user_exts#reg"
    get "daren_apply_status" => "daren_applies#show"

  end

  get "app/test/app_about" => "about#app_about", :as => "app_about"
  get "app/test/app_business" => "about#app_business", :as => "app_business"
  get "web/web_version" => "home#index", :as => "web_version"


  get "weixin/app" => "weixin#app"
  get "weixin/sg_app" => "weixin#sg_app"
  get "weixin/app" => "weixin#app"
  get "app/android" => "weixin#android_download"

  get "about/info/brand_all" => "about#brand_all"

  get "about/info/fashion" => "about#fashion"

  get "about/info/website_map" => "about#website_map"

  get "about/info/trade" => "about#trade"

  get "about/info/member_introduce" => "about#member_introduce"

  get "about/info/get_password" => "about#get_password"

  get "about/info/help" => "about#help"

  get "about/info/report" => "about#report"

  get "about/info/recruitment" => "about#recruitment"

  get "about/info/brand_enter" => "about#brand_enter"

  get "about/info/collaborate" => "about#collaborate"

  get "about/info/advertisement" => "about#advertisement"

  get "about/info/merchant" => "about#merchant"

  get "about/info/contact" => "about#contact"
  get "about/info/cover" => "about#cover"
  get "about/info/mzsm" => "about#mzsm"

  get "about/shangou_option" => "about#shangou_option"

  get "collocations/mask_spec" => "collocations#mask_spec"
  get "collocations/text2image" => "collocations#text2image"

  get "collocations/hot_dapei_tags" => "collocations#hot_dapei_tags"
  get "info/hot_dapei_tags" => "collocations#hot_dapei_tags"
  get "info/publish_dapei_tags" => "collocations#publish_dapei_tags"
  get "info/dapei_themes" => "collocations#dapei_themes"
  get "info/app_banner" => "about#app_banner"
  get "info/app_banner_new" => "about#app_banner_new"
  get "info/dapei_banners" => "about#dapei_banners"

  get "info/daren_policy" => "policies#daren"
  get "info/dapei_tags" => "about#dapei_tags"


  get "info/activity_types" => "discounts#discount_types"

  resources :collocations do
    collection do
      get 'price_range'
      get 'app_template'
    end
  end


  get 'cgi/mystuff.things' => "collocations#mystuff_things"
  get 'cgi/like_matters' => "collocations#like_matters"

  post 'cgi/set.draft' => "collocations#set_draft"
  post 'cgi/template.publish' => "collocations#template_publish"
  post 'cgi/stats.record' => "collocations#stats_record"

  post 'cgi/favorite.add_thing' => "likes#create"
  post 'cgi/favorite.delete_thing' => "collocations#delete_thing"
  post 'cgi/favorite.delete_matter' => "collocations#delete_matter"

  get 'cgi/autocomplete.user_tagging' => "collocations#user_tagging"
  get 'cgi/autocomplete.user_hashtags' => "collocations#user_hastags"
  get 'cgi/autocomplete.price_ranges' => "collocations#price_ranges"
  get 'cgi/autocomplete.category_id_titles' => "collocations#category_id_titles"
  get 'cgi/autocomplete.categories' => "collocations#categories"
  get 'cgi/autocomplete.editor' => "collocations#editor"
  get 'cgi/template.load' => "collocations#template_load"
  get 'cgi/search.editor_things' => "collocations#editor_things"
  get 'cgi/search.sponsored_things' => "collocations#sponsored_things"
  get 'cgi/search.templates' => "collocations#templates"
  # post "/cgi/login.login" => "collocations#login_login"
  # get 'cgi/login' => "collocations#login"
  post "cgi/set.publish" => "collocations#publish"
  get "cgi/autocomplete.shop" => "collocations#shop"
  get 'cgi/collection.load' => "collocations#collection_load"

  get 'cgi/set.embed_html' => "collocations#embed_html"
  get 'cgi/autocomplete.tag_trends' => "collocations#tag_trends"
  get 'cgi/set.load' => "collocations#cgi_set_load"
  get 'cgi/set' => "collocations#cgi_set"

  get "dapeis/cgi/autocomplete.shop" => "collocations#shop"
  post "dapeis/cgi/stats.record" => "collocations#stats_record"
  get "dapeis/cgi/collection.load" => "collocations#collection_load"
  post 'cgi/comment.add' => "collocations#comment_add"

  get "cgi/item" => "collocations#item"
  get "cgi/collection.get" => "collocations#collection_get"
  get "cgi/mystuff.sets" => "collocations#mystuff_sets"
  get "cgi/mystuff.drafts" => "collocations#mystuff_drafts"
  get "cgi/mystuff.templates" => "collocations#mystuff_templates"
  get "uploads//cgi/img-thing/mask_spec/:spec/size/orig/tid/:image_name" => "collocations#mask_sepc"

  post "cgi/app.save_mask" => "collocations#save_mask"
  get "cgi/app.get_masks" => "collocations#get_masks"
  get "cgi/cut_templates" => "collocations#cut_templates"

  scope "admin" do
    resources :flinks
  end

  get "brands/info/web_index" => "brands#web_index", :as => "brands_web_index_old"
  get "brands/info/:id" => "brands#web_show", :as => "brands_web_show_old"

  resources :brands, :only => [:show]

  resources :recommends, :except => [:index]
  get "recommends/info/recommended_streets" => "recommends#recommended_streets"

  get "recommends/info/index" => "recommends#index", :as => "recommends"

  get "categories/index"
  get "about/feedback" => "about#feedback", :as => "feedback"
  post "about/send_feedback" => "about#create_feedback", :as => "create_feedback"
  get "about/version" => "about#version", :as => "version"
  get "about/wanhuir_version" => "about#wanhuir_version", :as => "wanhuir_version"
  get "about/shangou_version" => "about#shangou_version", :as => "shangou_version"

  get "about/info/about_me" => "about#about_me", :as => "about_me"
  get "about/apps" => "about#apps", :as => "abount_apps"
  get "about/download_app" => "about#download_app", :as => "download_app"

  get "/posts/new_index" => "posts#new_index"
  resources :posts do
    resources :comments, :only => [:index, :create, :destroy], :name_prefix => "post_"
  end

  resources :feedbacks

  get "notifications/index"
  get "notifications/index_new" => "notifications#index1"
  get "notifications/index_notify" => "notifications#notify"
  #get ':id'=>'shops#show', :constraints => { :id => /[A-Za-z0-9\-_]+/ }

  post 'shops/:id/update' => "shops#update"
  post 'devices/register' => "devices#register"

  get 'shops/info/recommended' => 'shops#recommended', :as => "recommended_shops"
  get 'shops/info/index_all' => 'shops#index_all', :as => "shops_all"
  get 'shops/:id/shop_items' => 'shops#shop_items'
  get 'shops/:id/shop_discounts' => 'shops#shop_discounts'
  get 'items/index_all' => 'items#index_all', :as => "items_all"
  get 'items/recommend_item/:id' => 'items#recommend_item', :as => "recommend_item"
  get 'items/warn_no_right' => 'items#warn_no_right', :as => 'warn_no_right'
  get 'discounts/index_all' => 'discounts#index_all', :as => "discounts_all"
  get 'discounts/recommended' => 'discounts#recommended', :as => "recommended_discounts"
  get 'discounts/recommend_discount/:id' => "discounts#recommend_discount", :as => "recommend_discount"
  get 'brands/recommend_brand/:id' => "brands#recommend_brand", :as => "recommend_brand"
  get 'dapeis/recommend_dapei/:id' => "items#recommend_dapei", :as => "recommend_dapei"
  get 'dapeis/like_dapei/:id' => "dapeis#like_dapei", :as => "like_dapei"
  get 'dapeis/follow_dapei_author/:id' => "dapeis#follow_dapei_author", :as => "follow_dapei_author"
  
  get 'dapeis/:dapei_id/get_dapei_detail' => "dapeis#get_dapei_detail", :as => "get_dapei_detail"
  get 'items/:item_id/get_item_detail' => "items#get_item_detail", :as => "get_item_detail"

  get 'shops/info/search' => 'shops#search', :as => "search"
  get 'shops/info/map_address' => 'shops#map_address', :as => "map_address"
  get 'shops/info/search_by_map' => 'shops#search_by_map', :as => "search_by_map"
  #get 'shop/:id/authenticate' => 'shops#authenticate', :as=>"authenticate_shop"
  get 'shops/info/test' => 'shops#test', :as => 'shop_test'
  get 'shops/info/test1' => 'shops#test1', :as => 'shop_test1'

  get 'info/item_categories' => "categories#group", :as => 'item_category'
  get 'info/brand_tags' => "brands#brand_tags", :as => 'info_brand_tags'

  get 'cat/search_dapei' => "categories#for_dapei", :as => 'category_dapei'

  resources :shops do
    resources :items do
      get :next
      get :prev
    end
    resources :follows, :only => [:create, :destroy]
    resources :comments, :only => [:index, :create, :destroy], :name_prefix => "shop_"
    resources :discounts
  end

  resources :items do
    resources :comments, :only => [:index, :create, :destroy], :name_prefix => "item_"
    resources :discounts
  end

  devise_for :users, :path => "accounts/info", :controllers => {:sessions => "sessions", :passwords => "passwords", :registrations => "registration", :omniauth_callbacks => "authentications"}

  devise_scope :user do
    match '/accounts/change_password', :to => 'registration#change_password', :as => "change_password"
    match '/accounts/getting_started', :to => 'registration#getting_started', :as => "getting_started"
    match '/accounts/layer_sign_in', :to => 'sessions#layer_create', :as => "layer_sign_in"
  end


  post "/follows/create_many" => "follows#create_many"
  post "/follows/destroy_many" => "follows#destroy_many"

  resources :users, :only => [:show, :index] do
    resources :follows, :only => [:create, :destroy]
    resources :posts do
      get :next
      get :prev
    end

    resources :site_helps, :only => [:eidt, :update] do
      collection do
        match :admin_help
      end
    end

  end

  delete 'users/:user_id/info/follow' => 'follows#destroy', :as => "delete_follow"

  resources :comments, :only => [:show, :destroy, :create]

  post 'users/send_code' => "users#send_code"
  post 'users/login_with_mobile' => "users#login_with_mobile"
  post 'users/verify_with_mobile' => "users#verify_with_mobile"

  get 'users/:id/favorite_items' => 'users#favorite_items', :as => "favorite_items"
  get 'users/:id/favorite_dapeis' => 'users#favorite_dapeis', :as => "favorite_dapeis"
  get 'users/:id/favorite_collections' => 'users#favorite_collections', :as => "favorite_collections"

  get 'users/:id/favorite_shops' => 'users#favorite_shops', :as => "favorite_shops"
  get 'users/:id/favorite_discounts' => 'users#favorite_discounts', :as => "favorite_discounts"
  get 'users/:id/favorite_brands' => 'users#favorite_brands', :as => "favorite_brands"
  get 'users/:id/created_dapeis' => 'users#created_dapeis', :as => "created_dapeis"
  get 'users/:id/shangjie_dapeis' => 'users#shangjie_dapeis', :as => "shangjie_dapeis"

  get 'users/:id/ssq' => 'users#ssq', :as => "ssq"
  get 'users/:user_id/my_ssq' => 'users#ssq', :as => "my_ssq"
  get 'users/:user_id/push' => 'users#push', :as => "push"

  get 'users/:id/ssq_status' => 'users#ssq_status', :as => "ssq_status"

  get 'users/:id/commented_shops' => 'users#commented_shops', :as => "commented_shops"
  get 'users/:id/commented_items' => 'users#commented_items', :as => "commented_items"
  get 'users/:id/followers' => 'users#followers', :as => "followers"
  get 'users/:id/followings' => 'users#followings', :as => "followings"
  get 'users/info/recommended' => 'users#recommended'
  get 'users/info/recommended_new' => 'users#recommended_new'

  get 'users/info/get_user_info' => "users#get_user_info"
  get 'users/info/index_all' => "users#index_all"
  get 'users/:id/unread_count' => 'users#get_unread_count', :as => "unread_count"
  post 'auth/info/auth_login' => 'users#auth_login'

  get 'users/posts/:id' => "posts#show"
  get 'info/current_user' => "users#get_user_info"

  get 'users/send_code' =>'Users#send_code'
  get 'users/resend_code' => 'Users#resend_code'

  resources :photos, :except => [:index] do
    put :make_profile_photo
  end

  resources :categories, :only => [:index]

  scope "/social" do
    resources :likes, :only => [:create, :destroy]
    get "dislike" => "likes#dislike"
  end
  get 'items/:id/liked_users' => 'items#like_users', :as => "item_like_users"
  get 'items/:id/like_users' => 'items#like_users', :as => "item_like_users"
  get 'brands/:id/like_users' => 'brands#like_users', :as => "brand_like_users"

  get 'items/recommend/index' => 'items#recommended_items', :as => "recommended_items"
  get 'posts/:id/liked_users' => 'posts#like_users', :as => "post_like_users"
  get 'brands/:id/liked_users' => 'brands#like_users', :as => "brand_like_users"
  get 'info/search' => 'search#index', :as => 'common_search'

  post 'photos/parse_raw_url' => 'photos#parse_raw_url'
  post 'photos/get_pic' => 'photos#get_pic'

  get 'stat/report' => 'stat#report', :as => "report"
  get 'shop/open' => 'shops#new'
  get ':shop_id/item/new' => 'items#new', :as => "items_new_path"
  get ":shop_id/:id.htm" => 'items#show', :as => "items_path"
  get "site/sitemap" => "sitemap#index"
  get "site/sitemap/:prefix" => "sitemap#index"


  resources :notifications, :only => [:update] do
    collection do
      put 'update_all'
    end
  end

  get 'api/weixin' => 'weixin#show', :as => "weixin"
  get 'api/weixin/test' => 'weixin#test', :as => "weixin_test"
  post 'api/weixin' => 'weixin#create', :as => "weixin_path"

  get 'api/dianping' => 'dianping#show', :as => "dianping"
  get 'api/dianping/test' => 'dianping#test', :as => "dianping_test"
  get 'api/redirect' => 'home#redirect', :as => "redirect"

  get 'weixin/shop' => 'weixin#shop', :as => "weixin_shop"
  get 'weixin/item' => 'weixin#item', :as => "weixin_item"
  get 'weixin/sku' => 'weixin#sku', :as => "weixin_sku"

  get 'weixin/brand' => 'weixin#brand', :as => "weixin_brand"
  get 'weixin/brands' => 'weixin#brands', :as => "weixin_brands"

  get 'weixin/posts' => 'weixin#posts', :as => "weixin_posts"
  get 'weixin/posts/:id' => 'weixin#post', :as => "weixin_post"
  get 'weixin/cities' => 'weixin#cities', :as => "weixin_cities"

  get 'weixin/games' => 'weixin#games', :as => "weixin_games"

  get 'weixin/discount' => 'weixin#discount', :as => "weixin_discount"
  get 'weixin/dapeis' => 'weixin#dapeis', :as => "weixin_dapeis"
  get 'weixin/dapei' => 'weixin#dapei', :as => "weixin_dapei"

  get 'weixin/search' => 'weixin#search', :as => "weixin_search"
  get 'weixin/s/:option.html' => 'weixin#search', :as => "weixin_search_1"
  get 'weixin/help' => 'weixin#help', :as => "weixin_help"
  get 'weixin/homepage' => 'weixin#homepage', :as => "weixin_homepage"
  get 'weixin/homepage2' => 'weixin#homepage2', :as => "weixin_homepage2"

  get 'weixin/download' => 'weixin#download'

  get 'dapeis/view/:url' => 'dapeis#view', :as => "dapei_view"
  get 'dapeis/index_all' => 'dapeis#index'
  get 'dapeis/collections' => 'dapeis#collections'
  get 'dapeis/collections_rabl' => 'dapeis#collections_rabl'

  get 'dapeis/:id/collection_show' => 'dapeis#collection_show'
  get 'dapeis/:id/collection_items' => 'dapeis#collection_items'

  get 'dapeis/:id/share_selfie' => 'dapeis#share_selfie'
  get 'dapeis/recommend' => 'dapeis#recommend'
  get 'dapeis/get_dp_items/:url' => 'dapeis#get_dp_items'
  get 'dapeis/get_like_users/:url' => 'dapeis#get_like_users'
  get 'dapeis/info/recommended' => 'dapeis#recommended'

  get 'dapeis/by_item' => 'dapeis#by_item'
  get 'matters/:id/dapeis' => 'matters#get_dapeis'
  get 'dapeis/theme/:theme_id' => 'dapeis#theme'
  get 'dapeis/theme_view/:theme_id' => 'dapeis#theme_view'


  # API
  get '/dapeis/recommended_star_dapeis' => "dapeis#recommended_star_dapeis"
  get '/dapeis/:id/promote' => "dapeis#promote"
  # API END

  get 'spiders/js/:brand_id' => 'spiders#casperjs'
  get 'spiders/spider_scheduler/:spider_id' => 'spiders#spider_scheduler'
  get 'spiders/scheduler/:brand_id' => 'spiders#scheduler'
  get 'spiders/spider_crawler/:spider_id' => 'spiders#spider_crawler'
  get 'spiders/spider_soldout/:spider_id' => 'spiders#spider_soldout'
  get 'spiders/yintai_spider_soldout/:spider_id' => 'spiders#yintai_spider_soldout'
  get 'spiders/spider_price/:spider_id' => 'spiders#spider_price'
  get 'spiders/spider_now_price/:spider_id' => 'spiders#spider_now_price'
  get 'spiders/spider_sizes_color/:spider_id' => 'spiders#spider_sizes_color'
  get 'spiders/crawler/:brand_id' => 'spiders#crawler'
  get 'spiders/soldout/:brand_id' => 'spiders#soldout'
  get 'tshow_spiders/spider_scheduler/:spider_id' => 'tshow_spiders#spider_scheduler'
  get 'tshow_spiders/scheduler/:brand_id' => 'tshow_spiders#scheduler'
  get 'tshow_spiders/spider_crawler/:spider_id' => 'tshow_spiders#spider_crawler'
  get 'tshow_spiders/crawler/:brand_id' => 'tshow_spiders#crawler'


  get 'spiders/new_crawler/:spider_id' => 'spiders#new_crawler'
  get 'spiders/new_scheduler/:spider_id' => 'spiders#new_scheduler'


  get 'spiders/list' => 'spiders#index'
  get 'spiders/schedule_list/:templateid' => 'spiders#schedule_index'
  get 'tshow_spiders/schedule_list/:templateid' => 'tshow_spiders#schedule_index'
  get 'spiders/crawl_list/:templateid' => 'spiders#crawl_index'
  get 'tshow_spiders/crawl_list/:templateid' => 'tshow_spiders#crawl_index'
  get 'spiders/soldout_list/:templateid' => 'spiders#soldout_index'
  get 'spiders/soldout_list_tmall' => 'spiders#soldout_index_tmall'
  get 'spiders/schedule_list_tmall' => 'spiders#schedule_index_tmall'
  get 'spiders/crawl_list_tmall' => 'spiders#crawl_index_tmall'
  get 'spiders/schedule_list_authweb' => 'spiders#schedule_index_authweb'
  get 'spiders/crawl_list_authweb' => 'spiders#crawl_index_authweb'

  get 'spiders/create_sku' => 'spiders#create_sku'
  post 'spiders/create_sku' => 'spiders#create_sku'

  get 'info/check_update' => 'home#check_update'
  get 'info/check_update_new' => 'home#check_update_new'

  get 'spiders/info/:brand_id' => 'spiders#show'

  #-------------------2013--------------

  constraints subdomain: 'm' do
    #root :to => 'weixin#homepage'
    root :to => redirect("/shangjieba/index.html")
  end

  #root :to => "home#index"
  root :to => "dapeis#index"

  resources :dapeis do
    resources :comments, :only => [:index, :create, :destroy], :name_prefix => "item_"
  end


end
