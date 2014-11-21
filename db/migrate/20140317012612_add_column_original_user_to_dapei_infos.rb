# -*- encoding : utf-8 -*-
class AddColumnOriginalUserToDapeiInfos < ActiveRecord::Migration
  def change
    add_column :dapei_infos, :original_id, :integer
  end
end
