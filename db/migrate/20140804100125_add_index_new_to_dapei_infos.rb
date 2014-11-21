# -*- encoding : utf-8 -*-
class AddIndexNewToDapeiInfos < ActiveRecord::Migration
  def change
    add_index "dapei_infos", ["dapei_tags_id"]
  end
end
