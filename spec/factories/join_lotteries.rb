# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :join_lottery do
    user_id 1
    lottery_id 1
    result 1
  end
end
