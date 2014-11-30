# -*- encoding : utf-8 -*-

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
file_to_load  = Rails.root + 'db/seed/categories_new.yml'
categories_list   = YAML::load( File.open( file_to_load ) )
categories_list.each_pair do |key,category|
  s = Category.find_by_id(category['id'])
  Category.create(category) unless s
end

admin_file =  Rails.root + 'db/seed/admin.yml'
admin_list = YAML::load( File.open(admin_file) )
admin_list.each_pair do |key, value|
  ad = User.find_by_email(value['email'])
  unless ad
    admin_user=User.create(value)
  end
end

