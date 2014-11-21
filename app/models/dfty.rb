# -*- encoding : utf-8 -*-
class Dfty < ActiveRecord::Base
  attr_accessible :address, :invite_name1, :invite_name2, :invite_name3, :invite_name4, :invite_name5, :name, :ship_address, :ship_name, :tel, :user_id
  belongs_to :user
  
  validates :ship_address, :presence => true
  validates :tel, :presence => true
  validates :ship_name, :presence => true
  
  validates :invite_name1, :presence => true 
  validates :invite_name2, :presence => true 
  validates :invite_name3, :presence => true 
 
  scope :join, lambda {
    where("user_id > 0 and tel is not null").order("created_at desc")
  }
end
