# -*- encoding : utf-8 -*-
class AddIndexToDapeiInfos < ActiveRecord::Migration
  def change
    add_index :dapei_infos, :start_date
    add_index :dapei_infos, :end_date
  end
end
