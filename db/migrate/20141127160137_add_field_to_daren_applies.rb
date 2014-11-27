class AddFieldToDarenApplies < ActiveRecord::Migration
  def change
    add_column :daren_applies, :contact, :string
    add_column :daren_applies, :phone, :string
    add_column :daren_applies, :apply_type, :integer
    add_column :daren_applies, :production_type, :integer
    add_column :daren_applies, :site, :string
    add_column :daren_applies, :matter_display_name, :string
    add_column :daren_applies, :brand_id, :integer
  end
end
