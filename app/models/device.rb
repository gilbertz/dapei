# -*- encoding : utf-8 -*-
class Device < ActiveRecord::Base
  attr_accessible :enabled, :token, :user_id, :platform, :udid
  belongs_to :user
  validates_uniqueness_of :token, :scope => :user_id
  acts_as_api
  api_accessible :public ,  :cache => 300.minutes do |t|
    t.add :user_id
    t.add :udid
    t.add :token
    t.add :platform
  end
  api_accessible :error do |t|
    t.add :errors
  end
end
