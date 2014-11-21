# -*- encoding : utf-8 -*-
class M::BaseController < ActionController::Base

  protect_from_forgery

  layout "m/layouts/base"


  rescue_from StandardError do |exception|
    new_logger = Logger.new('log/m_exceptions.log')
    new_logger.info("THIS IS A NEW EXCEPTION! #{Time.now.to_s}")
    new_logger.info(request.url)
    new_logger.info(params.to_s)
    new_logger.info(exception.message)
    new_logger.info(exception.backtrace.join("\n"))
    raise exception
  end


end
