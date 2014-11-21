# -*- encoding : utf-8 -*-
class AddColumnIsShowToDapeiInfo < ActiveRecord::Migration
  def change
    add_column :dapei_infos, :is_show, :integer, :default => 1
  end
end
