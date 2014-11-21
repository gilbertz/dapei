# -*- encoding : utf-8 -*-
class AddTagsToDapeiInfos < ActiveRecord::Migration
  def change
    add_column :dapei_infos, :tags, :string

  end
end
