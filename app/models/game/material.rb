# -*- encoding : utf-8 -*-
module Game
  class Material < ActiveRecord::Base
    self.table_name = "game_materials"
    has_many :images, as: :viewable, class_name: "Game::Image", dependent: :destroy
    has_many :answers, as: :viewable, class_name: "Game::Answer",  dependent: :destroy
    belongs_to :category, class_name: "Game::Category"

    class_attribute :clone
    before_update :clone_self, if: Proc.new{|mate| mate.clone == true}

    def cloning(param)
      self.update_attribute(:clone,param)
    end

    private
    def clone_self
      material = Material.new self.attributes.except!("created_at")
      material.images = self.images.map{|img| Image.new img.attributes}
      material.answers = self.answers.map{|asw| Answer.new asw.attributes} 
      material.save
    end
  end
end
