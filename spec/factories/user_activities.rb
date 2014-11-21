# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_activity do
    user_id 1
    action "MyString"
    object_type "MyString"
    object "MyString"
  end
end
