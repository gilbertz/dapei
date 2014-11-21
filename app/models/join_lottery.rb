# -*- encoding : utf-8 -*-
class JoinLottery < ActiveRecord::Base
  acts_as_api
  api_accessible :public, :cache => 300.minutes do |t|
    t.add :result
    t.add :qq
    t.add :name
    t.add :tel
    t.add :app_market_id
    t.add :email
    t.add :get_user, :as => :user, :template => :light
  end

  
  def get_user
    if self.user_id
      u = User.find_by_id(self.user_id)
      if u
        return u
      end
    end
    User.find_by_id(1)
  end

end
