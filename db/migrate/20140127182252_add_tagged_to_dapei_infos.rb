# -*- encoding : utf-8 -*-
class AddTaggedToDapeiInfos < ActiveRecord::Migration
  def change
    add_column :dapei_infos, :tagged, :boolean

  end
end
