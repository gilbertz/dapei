# -*- encoding : utf-8 -*-
Shangjieba::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # ActionMailer Config
  #config.action_mailer.default_url_options = { :host => 'www.shangjieba.com' }
  config.action_mailer.delivery_method = :smtp
  # change to true to allow email to be sent during development
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default :charset => "utf-8"

  config.action_mailer.smtp_settings = {
    address: "smtp.mail1.weixinjie.net",
    port: 25,
    domain: "weixinjie.net",
    authentication: "login",
    enable_starttls_auto: true,
    user_name: "noreply@weixinjie.net",
    password: "111111"
  }
  #
  #config.action_mailer.smtp_settings = {
  #    address: "smtp.mail1.weixinjie.net",
  #    port: 25,
  #    domain: "weixinjie.net",
  #    authentication: "login",
  #    enable_starttls_auto: true,
  #    user_name: "noreply@weixinjie.net",
  #    password: "111111"
  #}
  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

end

SPHINX_HOST = '114.80.100.12'
REDIS_HOST = '127.0.0.1'
#REDIS_CRAWLER_HOST = '127.0.0.1'
#SG_DOMAIN = 'http://127.0.0.1:3001'
#COLOR_EXTRACTOR_URL='http://wx.shangjieba.com:7777/service/dapei/get_color'

#SPHINX_HOST = 'localhost'
#REDIS_HOST = 'localhost'
REDIS_CRAWLER_HOST = '114.80.100.12'
SG_DOMAIN = "http://sg.wanhuir.com:7777"
COLOR_EXTRACTOR_URL='http://wx.shangjieba.com:7777/service/dapei/get_color'  
