# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :test_model do
    name "Chuck"
    surname "Norris"
    email_address "masciugo@gmail.com"
    extra_id "XX00000"
  end
end
