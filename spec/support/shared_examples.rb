module LimesurveyRails
  module SharedExamples

    shared_examples "removing a participant" do |method|
      context "when they are regularly registered" do
        before(:each) { test_survey.add_participant(a_participant) }
        it "returns true" do
          expect(test_survey.send(method,a_participant)).to be true
        end
        describe "what happens on Limesurvey" do
          before(:each) do
            @deleted_tid = a_participant.survey_participations.for_survey(test_survey.id).token_id
            test_survey.send(method,a_participant)
          end
          it "survey doesn't include participant" do
            expect(LimesurveyRails.list_participants(test_survey.id).map{|p| p['tid']}).not_to include(@deleted_tid)
          end
          describe "#survey_participations.for_survey(survey_id)" do
            specify { expect(a_participant.survey_participations.for_survey(test_survey.id)).to be_nil }
          end
        end
      end
    end

    shared_examples "adding a participant" do |method|
      context "when they are not registered" do
        it "returns true" do
          expect(test_survey.send(method,a_participant)).to be true
        end
        describe "what happens on Limesurvey" do
          before(:each) { test_survey.send(method,a_participant) }
          it "is present" do
            expect(LimesurveyRails.list_participants(test_survey.id).map { |p| p["tid"] }).to include(a_participant.survey_participations.for_survey(test_survey.id).token_id)
          end
          ['email', 'firstname', 'lastname'].each do |a|
            it "has correct value for attribute #{a}" do
              token_value = LimesurveyRails.get_participant_properties(test_survey.id,'1',[a])[a]
              participant_value = a_participant.send(TestModel.send("limesurvey_participant_#{a}_attr"))
              expect(token_value).to eq(participant_value)
            end
          end
          it "has correct value for attribute attribute_1" do
            token_value = LimesurveyRails.get_participant_properties(test_survey.id,'1',['attribute_1'])['attribute_1']
            participant_value = a_participant.send(TestModel.send("limesurvey_participant_attribute_1_attr"))
            expect(token_value).to eq(participant_value)
          end

          describe "#survey_participations.for_survey(survey_id)" do
            specify { expect(a_participant.survey_participations.for_survey(test_survey.id)).to ar_eql(LimesurveyRails::SurveyParticipation.last) }
          end
        end
      end
    end

  end
end
