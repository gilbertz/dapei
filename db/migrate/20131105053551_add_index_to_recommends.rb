# -*- encoding : utf-8 -*-
class AddIndexToRecommends < ActiveRecord::Migration
  def change
     add_index :recommends, [:recommended_type, :recommended_id]
  end
end
