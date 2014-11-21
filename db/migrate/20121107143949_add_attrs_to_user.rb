# -*- encoding : utf-8 -*-
class AddAttrsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :is_girl, :boolean, :default=>1
    add_column :users, :birthday, :datetime
    add_column :users, :age, :integer
    add_column :users, :city, :string
    add_column :users, :district, :string
    add_column :users, :getting_started, :boolean, :default=>1
    add_column :users, :avatar, :string
    add_column :users, :nickname, :string
    add_column :users, :real, :boolean, :defaut=>1

    add_index  :users, :name, :unique=>true
    
  end
  def self.down
    remove_index  :users, :name

    remove_column :users, :is_girl
    remove_column :users, :birthday
    remove_column :users, :age
    remove_column :users, :city
    remove_column :users, :district
    remove_column :users, :getting_started
    remove_column :users, :avatar
    remove_column :users, :nickname
  end
end
