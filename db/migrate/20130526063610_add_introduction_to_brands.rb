# -*- encoding : utf-8 -*-
class AddIntroductionToBrands < ActiveRecord::Migration
  def change
    add_column :brands, :introduction, :string

  end
end
