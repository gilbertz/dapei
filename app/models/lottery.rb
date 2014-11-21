# -*- encoding : utf-8 -*-
class Lottery < ActiveRecord::Base
  
  acts_as_api
  api_accessible :public do |t|
    t.add :title
    t.add :start_date
    t.add :end_date
    t.add :desc
    t.add :link
    t.add :img_url
    t.add :award
    t.add :type_id
    t.add :on
  end

end
