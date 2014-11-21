# -*- encoding : utf-8 -*-
class Monitor::MonitorController < ActionController::Base

  http_basic_authenticate_with name: "shangjieba", password: "shangjieba123"
  layout 'monitor/layouts/monitor'

  rescue_from StandardError do |exception|
    new_logger = Logger.new('log/monitor_exceptions.log')
    new_logger.info("THIS IS A NEW EXCEPTION! #{Time.now.to_s}")
    new_logger.info(request.url)
    new_logger.info(params.to_s)
    new_logger.info(exception.message)
    new_logger.info(exception.backtrace.join("\n"))
    raise exception
  end


end
