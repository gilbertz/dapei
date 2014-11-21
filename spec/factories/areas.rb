# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :area do
    name "MyString"
    city "MyString"
    city_id 1
    type ""
    parent "MyString"
    parent_dp_id 1
    dp_id 1
  end
end
