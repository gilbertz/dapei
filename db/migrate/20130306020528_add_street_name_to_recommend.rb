# -*- encoding : utf-8 -*-
class AddStreetNameToRecommend < ActiveRecord::Migration
  def change
    add_column :recommends, :name, :string
  end
end
