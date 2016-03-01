# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :code_check do
    code "MyString"
    valid false
  end
end
