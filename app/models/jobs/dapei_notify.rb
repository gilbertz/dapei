# -*- encoding : utf-8 -*-
#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Jobs
  class DapeiNotify < Base
    @queue = :dapei_notify
    def self.perform(url)
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
end
