# -*- encoding : utf-8 -*-
#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Jobs
  class Monitor < Base
    @queue = :monitor
    def self.perform(p)
      begin
        monitor_record = MonitorRecord.new
        monitor_record.controller = params[:controller]
        monitor_record.action = params[:action]
        monitor_record.request_type = request.request_method
        monitor_record.request_params = request.fullpath
        monitor_record.original_url = request.original_url
        monitor_record.remote_ip = request.remote_ip
        monitor_record.http_agent = request.env['HTTP_USER_AGENT']
        monitor_record.user_id = current_user.id if current_user
        monitor_record.save
      rescue
         MonitorRecord.create
      end
    end
  end
end
