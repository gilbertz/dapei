class Card < ActiveRecord::Base
  attr_accessible :app_id, :ibeacon_id, :card_id, :on, :shop_id
end
