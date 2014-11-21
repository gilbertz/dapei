# -*- encoding : utf-8 -*-
module Game
  class Category < ActiveRecord::Base
    self.table_name = "game_categories"
    has_many :images, as: :viewable, class_name: "Game::Image" 
    has_many :materials, class_name: "Game::Material"
  end
end
