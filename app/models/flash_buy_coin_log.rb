# encoding: utf-8
class FlashBuyCoinLog < ActiveRecord::Base
  # attr_accessible :title, :body

  belongs_to :user
  belongs_to :relatable, :polymorphic => true
  scope :query_relatable , ->(relatable){ where(:relatable_id => relatable.id,:relatable_type => relatable.class.name)}


  # 单表继承多态的问题
  def relatable=(obj)
    self.relatable_type = obj.class.name
    self.relatable_id = obj.id
  end

  def self.create_coin_log(user, relatable, type, direction, value)
    log = user.flash_buy_coin_logs.build
    log.relatable = relatable
    log.coin_type = type
    log.direction = direction
    log.coin = value
    log.save!
  end
end
