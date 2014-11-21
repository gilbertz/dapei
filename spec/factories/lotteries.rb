# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :lottery do
    title "MyString"
    desc "MyText"
    start_date "2013-12-04"
    end_date "2013-12-04"
    award "MyString"
    type_id 1
  end
end
