# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :limesurvey_rails_survey_participation, :class => 'LimesurveyRails::SurveyParticipation' do
    participant_id 1
    survey_id 1
    token_id '1'
  end
end
