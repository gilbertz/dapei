# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :honour do
    user_id 1
    name "MyString"
    img "MyString"
    url "MyString"
    active false
  end
end
