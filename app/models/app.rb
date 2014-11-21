# -*- encoding : utf-8 -*-
class App < ActiveRecord::Base
  acts_as_api
  api_accessible :public,  :cache => 300.minutes do |t|
    t.add :name
    t.add :dev_name
    t.add :desc
    t.add :icon_url
    t.add :app_type
    t.add :ios_id
    t.add :click_url
    t.add :url_scheme
    t.add :weight
    t.add :on
  end

end
