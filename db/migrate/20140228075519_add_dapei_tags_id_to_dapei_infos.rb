# -*- encoding : utf-8 -*-
class AddDapeiTagsIdToDapeiInfos < ActiveRecord::Migration
  def change
    add_column :dapei_infos, :dapei_tags_id, :integer

  end
end
