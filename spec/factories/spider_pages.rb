# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :spider_page, :class => 'SpiderPages' do
    name "MyString"
    link "MyString"
    category_id ""
    parent_id ""
    brand_id 1
    user_id 1
  end
end
