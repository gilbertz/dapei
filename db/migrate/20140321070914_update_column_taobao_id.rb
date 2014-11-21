# -*- encoding : utf-8 -*-
class UpdateColumnTaobaoId < ActiveRecord::Migration
  def up
    change_column :matter_infos, :taobao_id, :integer, :limit => 8
  end

  def down
  end
end
