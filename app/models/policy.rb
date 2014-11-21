# -*- encoding : utf-8 -*-
class Policy < ActiveRecord::Base
  acts_as_api
  api_accessible :public, :cache => 60.minutes do |t|
    t.add :titlle
    t.add :desc
    t.add :condition
    t.add :priority
    t.add :policy_type
    t.add :created_at
  end

end
