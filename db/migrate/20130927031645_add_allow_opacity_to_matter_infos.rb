# -*- encoding : utf-8 -*-
class AddAllowOpacityToMatterInfos < ActiveRecord::Migration
  def change
    add_column :matter_infos, :allow_opacity, :string
  end
end
