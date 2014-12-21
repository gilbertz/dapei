# -*- encoding : utf-8 -*-
# Load the rails application
require File.expand_path('../application', __FILE__)

#
#if Rails.env == "production"
#  Shangjieba::Application.config.middleware.use ExceptionNotifier,
#    :email_prefix => "wanhuir.com",
#    :sender_address => %{nj@wanhuir.com},
#    :exception_recipients => ["77363218@qq.com","453567320@qq.com", "shangjieba@126.com"],
#   :delivery_method => :smtp,
#  :smtp_settings => {
#        :address => "smtp.wanhuir.com",
#        :port => "25",
#        :domain => "wanhuir.com",
#        :authentication => "login",
#        :user_name => "nj@wanhuir.com",
#        :password => "111111",
#        :enable_starttls_auto => true
#    },
#    :sections => %w(data request session environment backtrace)
#end

#RAILS_DEFAULT_LOGGER = Logger.new("#{RAILS_ROOT}/log/#{RAILS_ENV}.log", "daily")  


SPIDER_USER = 'root'
SPIDER_IP = '114.215.120.243'
SPIDER_PASS = '449e1fb5' 


# Initialize the rails application
Shangjieba::Application.initialize!
