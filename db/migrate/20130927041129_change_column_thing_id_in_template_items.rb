# -*- encoding : utf-8 -*-
class ChangeColumnThingIdInTemplateItems < ActiveRecord::Migration
  def up
    change_column :template_items, :thing_id, :integer, :limit => 8
  end

  def down
  end
end
