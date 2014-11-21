# -*- encoding : utf-8 -*-
class AddColumnToDapeiTag < ActiveRecord::Migration
  def change
    add_column :dapei_tags, :is_hot, :integer, :default => 0

  end
end
