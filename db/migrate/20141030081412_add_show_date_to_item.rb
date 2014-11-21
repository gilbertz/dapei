class AddShowDateToItem < ActiveRecord::Migration
  def change
    add_column :items, :show_date, :datetime
  end
end
