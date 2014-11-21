# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :meta_tag do
    tag "MyString"
    is_show 1
  end
end
