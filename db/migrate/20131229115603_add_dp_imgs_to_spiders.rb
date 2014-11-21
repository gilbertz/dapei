# -*- encoding : utf-8 -*-
class AddDpImgsToSpiders < ActiveRecord::Migration
  def change
    add_column :spiders, :dp_img, :string

    add_column :spiders, :update_period, :integer

    add_column :spiders, :last_updated, :datetime

  end
end
