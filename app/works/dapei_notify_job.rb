# encoding: utf-8
class DapeiNotifyJob

  include Sidekiq::Worker
  sidekiq_options :queue => :notify, :retry => false, :backtrace => true,
                  :unique => true, :unique_args => ->(args) { [args.first] }

  def perform(url)
    dp = Dapei.find_by_url(url)
    if dp and ( dp.category_id == 1000 or dp.category_id == 1001 )
      dp.user.followers_by_type('User').each do |user|
        unless user.is_fake
          user.set_ssq_status(dp)
          user.set_ssq_notify_img(dp.user_img_small)
          #user.query_notify
        end
      end
    end
  end
end