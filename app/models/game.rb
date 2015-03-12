class Game < ActiveRecord::Base
  attr_accessible :app_id, :game_id, :ibeacon_id, :shop_id
end
