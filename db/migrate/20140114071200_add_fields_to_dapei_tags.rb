# -*- encoding : utf-8 -*-
class AddFieldsToDapeiTags < ActiveRecord::Migration
  def change
    add_column :dapei_tags, :avatar_url, :string

    add_column :dapei_tags, :image_thing, :string

    add_column :dapei_tags, :synonym, :string

    add_column :dapei_tags, :weight, :integer

  end
end
