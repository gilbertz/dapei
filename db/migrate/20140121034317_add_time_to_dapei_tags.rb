# -*- encoding : utf-8 -*-
class AddTimeToDapeiTags < ActiveRecord::Migration
  def change
    add_column :dapei_tags, :updated_at, :datetime

    add_column :dapei_tags, :created_at, :datetime

  end
end
