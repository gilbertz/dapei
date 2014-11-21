# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sku do
    title "MyString"
    price "MyString"
    brand_id 1
  end
end
