# -*- encoding : utf-8 -*-
class AddFieledToDapeiTags < ActiveRecord::Migration
  def change
    add_column :dapei_tags, :user_id, :integer
    add_column :dapei_tags, :desc, :text
  end
end
