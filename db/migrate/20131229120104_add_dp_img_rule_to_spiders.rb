# -*- encoding : utf-8 -*-
class AddDpImgRuleToSpiders < ActiveRecord::Migration
  def change
    add_column :spiders, :dp_img_rule, :string

  end
end
