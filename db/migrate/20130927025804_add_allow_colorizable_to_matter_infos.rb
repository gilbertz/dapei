# -*- encoding : utf-8 -*-
class AddAllowColorizableToMatterInfos < ActiveRecord::Migration
  def change
    add_column :matter_infos, :allow_colorizable, :string
  end
end
