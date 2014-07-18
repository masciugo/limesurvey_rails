# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :limesurvey_rails_survey, :class => 'Survey' do
    title "MyString"
    lang "MyString"
  end
end
