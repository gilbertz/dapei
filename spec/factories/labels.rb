# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :label do
    sku_id 1
    name "MyString"
    weight 1
  end
end
