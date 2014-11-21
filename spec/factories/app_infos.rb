# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :app_info do
    code "MyString"
    version "MyString"
    ios_version "MyString"
    ios_app_url "MyString"
    feature "MyText"
    download_url "MyString"
    app_name "MyString"
    active false
  end
end
