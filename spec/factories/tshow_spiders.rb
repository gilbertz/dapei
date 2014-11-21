# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tshow_spider do
    stop false
    template_id 1
    start_page "MyText"
    is_template false
    images_start_page "MyText"
    show_date "2014-07-07"
    city "MyString"
    author "MyString"
    content "MyText"
    brand_id 1
    season "MyString"
  end
end
