# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :crawler_template do
    t "MyString"
    brand_name "MyString"
    brand_id 1
    template "MyString"
    pattern "MyString"
    skus_count 1
    status false
    last_skus_count 1
    source "MyString"
  end
end
