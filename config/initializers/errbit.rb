# -*- encoding : utf-8 -*-
if Rails.env == 'production'
    Airbrake.configure do |config|
	  config.api_key = '134c16eb27d6ca858cd78ec64f047193'
	  config.host    = '203.195.186.54'
	  config.port    = 6060
	  config.secure  = config.port == 443
    end
end

