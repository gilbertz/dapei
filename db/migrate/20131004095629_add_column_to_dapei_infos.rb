# -*- encoding : utf-8 -*-
class AddColumnToDapeiInfos < ActiveRecord::Migration
  def change
    add_column :dapei_infos, :width, :string
    add_column :dapei_infos, :height, :string
  end
end
