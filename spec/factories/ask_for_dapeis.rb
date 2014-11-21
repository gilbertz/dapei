# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ask_for_dapei do
    user_id 1
    matter_id 1
    level 1
    dapei_id 1
    likes_count 1
    comments_count 1
    dispose_count 1
    reward 1
  end
end
