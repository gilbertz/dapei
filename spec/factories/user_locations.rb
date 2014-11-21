# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_location, :class => 'UserLocations' do
    user_id 1
    jindu "MyString"
    weidu "MyString"
  end
end
