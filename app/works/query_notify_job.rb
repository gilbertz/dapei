# encoding: utf-8
class QueryNotifyJob
  include Sidekiq::Worker
  sidekiq_options :queue => :notify, :retry => false, :backtrace => true,
                  :unique => true, :unique_args => ->(args) { [args.first] }

  # sidekiq_retry_in do |count|
  #   1.days.to_i # 结算失败,每隔一天重试
  # end

  def perform(id)
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
  end

end