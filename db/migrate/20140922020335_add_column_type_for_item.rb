class AddColumnTypeForItem < ActiveRecord::Migration
  def up
    add_column :items, :type, :string
    Item.where(:category_id => 1001).update_all(:type => 'Dapei')
    Item.where(:category_id => 1000).update_all(:type => 'Collection')
  end

  def down
    remove_column :items, :type
  end
end
