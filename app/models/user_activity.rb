# -*- encoding : utf-8 -*-
class UserActivity < ActiveRecord::Base
  attr_accessible :action, :object, :object_type, :user_id, :by, :recommended
  belongs_to :user

  acts_as_api
  api_accessible :public,  :cache => 300.minutes do |t|
    t.add :action
    t.add :object_type
    t.add :object
    t.add :by
    t.add :created_at
    t.add :updated_at
  end


end
