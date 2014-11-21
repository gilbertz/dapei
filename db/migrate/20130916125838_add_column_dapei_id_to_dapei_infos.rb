# -*- encoding : utf-8 -*-
class AddColumnDapeiIdToDapeiInfos < ActiveRecord::Migration
  def change
  	add_column :dapei_infos, :dapei_id, :integer
  end
end
