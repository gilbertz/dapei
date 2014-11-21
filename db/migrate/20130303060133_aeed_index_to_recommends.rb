# -*- encoding : utf-8 -*-
class AeedIndexToRecommends < ActiveRecord::Migration
  def change
    add_index :recommends, :recommended_type
    add_index :recommends, :recommended_id
  end

end
