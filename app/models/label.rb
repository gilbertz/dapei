# -*- encoding : utf-8 -*-
class Label < ActiveRecord::Base
  #validates :name, :presence => true
  attr_accessible :name, :weight
  acts_as_api
  api_accessible :public, :cache => 180.minutes do |t|
    t.add :name
    t.add :weight
  end
end
