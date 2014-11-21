# -*- encoding : utf-8 -*-
class AddTypeIdToTags < ActiveRecord::Migration
  def change
    add_column :tags, :type_id, :integer
   
    add_index :tags, :type_id
  end
end
