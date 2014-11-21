# -*- encoding : utf-8 -*-
module Jobs
  class QueryNotify < Base
    @queue = :query_notify
    def self.perform(id)
        #log = Logger.new 'log/resque.log'
        #log.debug "begin"    
        user  = User.find_by_id(id)
        if user
          #log.debug id
          if  user.get_notify_read.to_i < user.get_notify_status.to_i 
            #log.debug "1"
            PushNotification.push_notify(id)
            #log.debug "2" 
          end
          if user.get_ssq_read.to_i < user.get_ssq_status.to_i
            #log.debug "3"
            PushNotification.push_ssq(id)
            #log.debug "4" 
          end

          if user.get_dapei_classroom_read.to_i < user.get_dapei_classroom_status.to_i
            PushNotification.push_dapei_classroom(id)
          end

        end
        user.query_notify_done
        #log.debug "end"
    end
  end
end
