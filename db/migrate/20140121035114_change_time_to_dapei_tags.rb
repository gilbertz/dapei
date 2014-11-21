# -*- encoding : utf-8 -*-
class ChangeTimeToDapeiTags < ActiveRecord::Migration
  def up
    change_column :dapei_tags, :created_at, :datetime, :null => false
    change_column :dapei_tags, :updated_at, :datetime, :null => false
  end

  def down
  end
end
