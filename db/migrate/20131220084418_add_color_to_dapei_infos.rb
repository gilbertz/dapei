# -*- encoding : utf-8 -*-
class AddColorToDapeiInfos < ActiveRecord::Migration
  def change
    add_column :dapei_infos, :color_one_id, :integer

    add_column :dapei_infos, :color_two_id, :integer

    add_column :dapei_infos, :color_three_id, :integer

  end
end
