# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :dapei_response do
    request_id 1
    user_id 1
    response_text "MyText"
    dapei_id 1
    likes_count 1
    comments_count 1
    dispose_count 1
    response_image "MyString"
  end
end
