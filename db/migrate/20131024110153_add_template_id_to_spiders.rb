# -*- encoding : utf-8 -*-
class AddTemplateIdToSpiders < ActiveRecord::Migration
  def change
    add_column :spiders, :template_id, :integer

  end
end
