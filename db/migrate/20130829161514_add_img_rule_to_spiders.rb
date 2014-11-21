# -*- encoding : utf-8 -*-
class AddImgRuleToSpiders < ActiveRecord::Migration
  def change
    add_column :spiders, :img_rule, :string

  end
end
