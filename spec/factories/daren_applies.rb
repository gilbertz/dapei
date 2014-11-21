# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :daren_apply do
    user_id 1
    mobile "MyString"
    qq "MyString"
    address "MyString"
    reason "MyText"
    photo1_id 1
    photo2_id 1
    photo3_id 1
    status 1
  end
end
