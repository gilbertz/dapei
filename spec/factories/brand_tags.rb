# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :brand_tag do
    name "MyString"
    thing_image_id 1
    type_id 1
    on false
  end
end
