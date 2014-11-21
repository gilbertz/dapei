# -*- encoding : utf-8 -*-
class AddTemplateSpecToMaskSpecs < ActiveRecord::Migration
  def change
    add_column :mask_specs, :matter_id, :integer
    add_column :mask_specs, :template_spec, :string
    add_index :mask_specs, :matter_id
    add_index :mask_specs, :template_spec    
    add_index :mask_specs, [:matter_id, :template_spec]
  end
end
