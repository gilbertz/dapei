class AddOffPercentToMatter < ActiveRecord::Migration
  def change
    add_column :matters, :off_percent, :integer
    add_column :matters, :origin_price, :integer
  end
end
