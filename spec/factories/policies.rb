# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :policy do
    titlle "MyString"
    desc "MyText"
    condition "MyText"
    policy_type 1
  end
end
