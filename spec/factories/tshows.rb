# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tshow do
    show_date "2014-07-07"
    city "MyString"
    author "MyString"
    content "MyText"
    brand_id 1
    season "MyString"
    tshow_spider_id 1
  end
end
