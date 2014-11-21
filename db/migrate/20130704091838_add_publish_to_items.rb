# -*- encoding : utf-8 -*-
class AddPublishToItems < ActiveRecord::Migration
  def change
    add_column :items, :publish, :string

  end
end
