#source 'https://rubygems.org'
source 'http://ruby.taobao.org'

gem 'rails', '3.2.14'

gem 'beaver'
#unicorn
#gem 'unicorn'
#gem 'unicorn-rails'
#gem 'unicorn-worker-killer'

#capistrano
gem 'capistrano', '~> 3.2.0'

# cache
gem 'dalli'
gem 'cache_digests'

# database
gem "activerecord-import", "~> 0.2.9"
gem 'foreigner', '~> 1.1.0'
gem 'mysql2', '0.3.11' if ENV['DB'].nil? || ENV['DB'] == 'all' || ENV['DB'] == 'mysql'
gem 'pg' if ENV['DB'] == 'all' || ENV['DB'] == 'postgres'
gem 'sqlite3' if ENV['DB'] == 'all' || ENV['DB'] == 'sqlite'
gem 'lol_dba'

gem "headless"
gem "selenium-webdriver"
# gem "redis", '~> 2.2.2'
gem "redis", '~> 3.1.0'
# 1.0.4
# gem 'redis-namespace' , '~> 1.3.1'
#email
#gem "roadie"

#http connect
gem 'faraday'
gem 'faraday_middleware'

#xml
gem 'xml-simple'

#user
gem 'rails_admin'

#crosslingual
gem 'chinese_pinyin'

gem 'grocer'
#gem 'jruby-openssl'

gem "taobaorb", :git => "https://github.com/wyh770406/taobaorb"

gem 'ransack', "1.1.0"
gem 'squeel', "1.1.1"
gem 'awesome_print'
#gem 'apn_sender'

# file uploading
gem 'carrierwave', '~> 0.10.0'
#gem 'fog' #cloud interface of rails
gem 'mini_magick', '~> 3.7.0'


#social features
gem 'acts_as_commentable', '3.0.1'
gem 'acts_as_follower', '0.1.1'
gem 'mailboxer', '0.8.0'

#url slug
gem 'stringex'
#gem 'babosa'

group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'turbo-sprockets-rails3', '~> 0.3.14'
end

# deploy
gem 'capistrano-rvm'
gem 'capistrano-bundler'
gem 'capistrano-rails'

gem 'jquery-rails' ,'~> 3.1.1'
#gem "thin", ">= 1.5.0"
gem "haml", ">= 3.1.7"
gem "haml-rails", ">= 0.3.5", :group => :development
gem "hpricot", ">= 0.8.6", :group => :development
gem "ruby_parser", ">= 2.3.1", :group => :development
gem "rspec-rails", ">= 2.13.2", :group => [:development, :test]
gem "json_spec", :group => [:development, :test]
gem "email_spec", ">= 1.2.1", :group => :test
gem "cucumber-rails", ">= 1.3.0", :group => :test, :require => false
gem "database_cleaner", ">= 0.9.1", :group => :test
gem "launchy", ">= 2.1.2", :group => :test
gem "capybara", ">= 1.1.2", :group => :test
gem "factory_girl_rails", ">= 4.1.0", :group => [:development, :test]
gem "bootstrap-sass", ">= 2.1.0.1"
gem "facebox-rails"
group :development do
  gem "better_errors"
  gem "binding_of_caller"
end

#user and authorization
gem "devise", "2.2.8"
gem "cancan", ">= 1.6.8"
gem "rolify", ">= 3.2.0"
gem 'omniauth'
gem 'oauth2'
gem 'omniauth-weibo-oauth2'
gem 'omniauth-qq-connect', '~> 0.1.0'
gem 'omniauth-weixin'
gem 'weibo_2'

gem "simple_form", ">= 2.0.4"
gem 'client_side_validations'
gem 'client_side_validations-simple_form'
gem "quiet_assets", ">= 1.0.1", :group => :development

gem "backbone-on-rails"
gem 'acts_as_api'

gem 'settingslogic' #, :git => 'git://github.com/binarylogic/settingslogic.git'
# gem 'resque', '1.20.0'
# gem 'resque-timeout', '1.0.0'
gem 'SystemTimer', '1.2.3', :platforms => :ruby_18
# gem 'will_paginate'
gem 'will_paginate-bootstrap'

gem 'whenever', :require => false
gem 'rest-client'

gem 'exception_notification', '3.0.0'
gem 'newrelic_rpm'
gem 'tinymce-rails'
gem 'tinymce-rails-langs'
gem 'rmmseg-cpp'
gem 'ruby-prof'

gem 'baidu_push'

gem 'rabl'
gem 'oj'
gem 'rmagick', '~> 2.13.3'
gem 'rails_kindeditor'

gem 'acts-as-taggable-on', '~> 3.4.0'

#performance
#gem "bullet", :group => "development"
#gem "query_reviewer", :group => "development"

#gem "slim_scrooge"

gem 'alipay', :github => 'chloerei/alipay' # 支付宝
gem 'passenger'

# 队列
gem 'sidekiq', '~> 2.17.8'
gem 'sinatra'
gem 'sidekiq-unique-jobs', '~> 3.0.2'
gem 'sidekiq-limit_fetch', '~> 2.2.6'
gem 'china_sms' # 推立方

# api 框架
gem 'grape'
gem 'grape-jbuilder'
gem 'jbuilder'
# gem 'rack-contrib'

gem 'qiniu', '~> 6.2.1'
gem 'weixin_authorize'
gem 'multi_json', '~>1.10.1'
gem 'roadie', '~> 2.4'
gem 'httpclient'

#http
gem 'mechanize'

# bug 监控
gem 'airbrake'
if RUBY_VERSION =~ /1.9/ # assuming you're running Ruby ~1.9
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end
