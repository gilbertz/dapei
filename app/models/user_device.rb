# -*- encoding : utf-8 -*-
class UserDevice < ActiveRecord::Base
                                                                                     
  acts_as_api                                                                      
  api_accessible :public, :cache => 60.minutes do |t|                              
    t.add :user_id                                                  
  end

end
