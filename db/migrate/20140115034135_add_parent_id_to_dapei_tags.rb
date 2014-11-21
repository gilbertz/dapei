# -*- encoding : utf-8 -*-
class AddParentIdToDapeiTags < ActiveRecord::Migration
  def change
    add_column :dapei_tags, :parent_id, :integer

  end
end
