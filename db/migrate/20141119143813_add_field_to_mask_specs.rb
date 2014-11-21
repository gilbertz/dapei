class AddFieldToMaskSpecs < ActiveRecord::Migration
  def change
    add_column :mask_specs, :mask_spec, :text
    add_column :mask_specs, :mask_spec_image_name, :string
  end
end
