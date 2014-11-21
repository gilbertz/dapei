# -*- encoding : utf-8 -*-
class AddColumnTaobaoIdToMatterInfos < ActiveRecord::Migration
  def change
    add_column :matter_infos, :taobao_id, :integer
  end
end
