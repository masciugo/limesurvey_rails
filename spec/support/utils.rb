def configure_and_connect
  LimesurveyRails.reset
  LimesurveyRails.configure do |config|
    config.api_url = LIMESURVEY_API_URL
    config.username = LIMESURVEY_USERNAME
    config.password = LIMESURVEY_PASSWORD
  end
  raise "can't connect to limesurvey (#{LimesurveyRails.configuration.api_url}) with user #{LimesurveyRails.configuration.username} and password #{LimesurveyRails.configuration.password}" unless LimesurveyRails.connect
end

def get_brand_new_test_survey_id(opts = {})
  id = LimesurveyRails.add_survey(nil,'LIMESURVEY_RAILS TEST','en')
  LimesurveyRails.activate_tokens(id,['1']) if opts[:activate_tokens]
  id
end

def remove_all_test_surveys
  all_test_surveys = LimesurveyRails.list_surveys(LimesurveyRails.configuration.username)
  all_test_surveys.each{|s| LimesurveyRails.delete_survey(s['sid'])}
end

# reload test model to reuse it among tests (mostly to reset variable classes...)
# http://stackoverflow.com/questions/14063395/rspec-class-variable-testing    
def reset_models
  # puts "resetting constants ..."
  if LimesurveyRails.const_defined? :Participant
    LimesurveyRails.send(:remove_const,:Participant)
    load File.join(ENGINE_RAILS_ROOT,'lib','limesurvey_rails','participant.rb')
  end

  if Object.const_defined? :TestModel
    Object.send(:remove_const,:TestModel) 
    load File.join(ENGINE_RAILS_ROOT,'spec','dummy','app','models','test_model.rb')
    # puts ">>>> TestModel.object_id: #{TestModel.object_id}"
  end
  
  if LimesurveyRails.const_defined? :SurveyParticipation
    LimesurveyRails.send(:remove_const,:SurveyParticipation)
    load File.join(ENGINE_RAILS_ROOT,'app','models','limesurvey_rails','survey_participation.rb')
    # puts ">>>> LimesurveyRails::SurveyParticipation.object_id: #{LimesurveyRails::SurveyParticipation.object_id}"
  end


  # puts "before LimesurveyRails::Participant         #{LimesurveyRails::Participant.object_id}"
  # puts "before TestModel                            #{TestModel.object_id}"
  # puts "before LimesurveyRails::SurveyParticipation #{LimesurveyRails::SurveyParticipation.object_id}"
  # ActiveSupport::Dependencies.remove_constant("LimesurveyRails::Participant")
  # ActiveSupport::Dependencies.remove_constant("LimesurveyRails::SurveyParticipation")
  # ActiveSupport::Dependencies.remove_constant("TestModel")
  # load File.join(ENGINE_RAILS_ROOT,'lib','limesurvey_rails','participant.rb')
  # load File.join(ENGINE_RAILS_ROOT,'app','models','limesurvey_rails','survey_participation.rb')
  # load File.join(ENGINE_RAILS_ROOT,'spec','dummy','app','models','test_model.rb')
  # puts "after LimesurveyRails::Participant         #{LimesurveyRails::Participant.object_id}"
  # puts "after TestModel                            #{TestModel.object_id}"
  # puts "after LimesurveyRails::SurveyParticipation #{LimesurveyRails::SurveyParticipation.object_id}"

  FactoryGirl.reload

  # puts "constants resetted"

end

