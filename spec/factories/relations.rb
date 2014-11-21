# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :relation do
    item_id 1
    target_type "MyString"
    target_id 1
  end
end
