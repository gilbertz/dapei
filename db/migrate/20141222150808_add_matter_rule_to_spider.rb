class AddMatterRuleToSpider < ActiveRecord::Migration
  def change
    add_column :spiders, :matter_rule, :string
  end
end
