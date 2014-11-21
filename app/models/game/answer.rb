# -*- encoding : utf-8 -*-
module Game
  class Answer < ActiveRecord::Base
    self.table_name = "game_answers"
    belongs_to :viewable, class_name: "Game::Material", polymorphic: true
  end
end
