# -*- encoding : utf-8 -*-
class Manage::BaseController < ActionController::Base
  before_filter :filter_ip
  http_basic_authenticate_with name: "dapeimishu", password: "dapei123"
  layout 'manage/layouts/manage'

  rescue_from StandardError do |exception|
    new_logger = Logger.new('log/manage_exceptions.log')
    new_logger.info("THIS IS A NEW EXCEPTION! #{Time.now} ")
    new_logger.info(request.url)
    new_logger.info(params.to_s)
    new_logger.info(exception.message)
    new_logger.info(exception.backtrace.join("\n"))
    raise exception
  end

  helper_method :a_name



  def a_name; action_name end

  private
  def filter_ip
    #if Rails.env == "production" && request.remote_ip != "222.67.41.252"
    #  render text: 'yi bian qu'
    #end
  end
end
