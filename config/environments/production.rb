# -*- encoding : utf-8 -*-
Shangjieba::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)
  config.logger = Logger.new("#{Rails.root}/log/#{Rails.env}-#{Date.today.to_s}.log", "daily")

  # Use a different cache store in production
  config.cache_store = :dalli_store
  # config.cache_store = :memory_store, { size: 512.megabytes }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )
  config.assets.precompile += %w( weixin.css )
  config.assets.precompile += %w( shangjieba_2013.css )
  config.assets.precompile += %w( shangjieba_2013.js )
  config.assets.precompile += %w( application_2013.css )
  config.assets.precompile += %w( about.css )
  config.assets.precompile += %w( jquery.js )
  config.assets.precompile += %w( jQueryRotateCompressed.js )
  config.assets.precompile += %w( basic.js )
  config.assets.precompile += %w( admin_game.js )
  config.assets.precompile += %w( manage.js manage.css )
  config.assets.precompile += %w( base.js base.css )
  config.assets.precompile += %w( admin.js admin.css )
  config.assets.precompile += %w( m.js )
  config.assets.precompile += %w( home_2014.js home_2014.css )
  config.assets.precompile += %w(site.css offline-css.css mk_offline_act.js )
  config.assets.precompile += %w(polyvore/*.css polyvore/*.js)
  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  #config.action_mailer.default_url_options = { :host => 'example.com' }
  # ActionMailer Config
  # Setup for production - deliveries, no errors raised
  #config.action_mailer.delivery_method = :smtp
  #config.action_mailer.perform_deliveries = true
  #config.action_mailer.raise_delivery_errors = false
  #config.action_mailer.default :charset => "utf-8"

  #config.action_mailer.smtp_settings = {
    #address: "smtp.gmail.com",
    #port: 587,
    #domain: "example.com",
    #authentication: "plain",
    #enable_starttls_auto: true,
    #user_name: ENV["GMAIL_USERNAME"],
    #password: ENV["GMAIL_PASSWORD"]
  #}

  # ActionMailer Config
  #config.action_mailer.default_url_options = { :host => 'www.shangjieba.com' }
  #config.action_mailer.delivery_method = :smtp
  # change to true to allow email to be sent during development
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default :charset => "utf-8"

  config.action_mailer.smtp_settings = {
    address: "smtp.wanhuir.com",
    port: 25,
    domain: "wanhuir.com",
    authentication: "login",
    enable_starttls_auto: true,
    user_name: "nj@wanhuir.com",
    password: "111111"
  }

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5
end
SPHINX_HOST = 'localhost'
REDIS_HOST = 'localhost'
REDIS_CRAWLER_HOST = '114.80.100.12'
SG_DOMAIN = "http://sg.wanhuir.com:7777"
COLOR_EXTRACTOR_URL='http://wx.shangjieba.com:7777/service/dapei/get_color'
