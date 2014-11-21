# -*- encoding : utf-8 -*-
class AddIsTemplateToSpiders < ActiveRecord::Migration
  def change
    add_column :spiders, :is_template, :boolean

  end
end
