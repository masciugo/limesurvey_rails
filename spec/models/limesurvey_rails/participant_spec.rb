require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

module LimesurveyRails
  describe TestModel, :participant do

    before(:context) do
      configure_and_connect
      remove_all_test_surveys
      # reset_models # uncomment to run all suite test in one single run
      @test_survey_id = get_brand_new_test_survey_id(:activate_tokens => true)
    end 
    after(:context) { remove_all_test_surveys }

    subject { TestModel }

    let(:a_participant) { FactoryGirl.create(:test_model) }
    let(:test_survey) { Survey.find(@test_survey_id) }

    context "when not initialized for being a participant" do
      before { reset_models }
      its(:is_a_limesurvey_participant_class?) { is_expected.to be false }
    end
    
    describe ".is_a_limesurvey_participant" do
      context "with no options" do
        before(:context) do
          reset_models
          TestModel.is_a_limesurvey_participant
        end
        it "has many survey_participations" do
          expect(subject.reflect_on_association(:survey_participations).macro).to be :has_many
        end
        its(:is_a_limesurvey_participant_class?) { is_expected.to be true }
        its(:limesurvey_participant_attribute_1_attr) { is_expected.to eq 'id' }
        its(:limesurvey_participant_email_attr) { is_expected.to be_nil }
        its(:limesurvey_participant_firstname_attr) { is_expected.to be_nil }
        its(:limesurvey_participant_lastname_attr) { is_expected.to be_nil }
      end
      context "with options :attribute_1_attr => 'other_id' " do
        before(:context) do
          reset_models
          TestModel.is_a_limesurvey_participant(:attribute_1_attr => 'other_id')
        end
        its(:is_a_limesurvey_participant_class?) { is_expected.to be true }
        its(:limesurvey_participant_attribute_1_attr) { is_expected.to eq 'other_id' }
      end
      context "with options :email_attr => 'email_address', :firstname_attr => 'name', :lastname_attr => 'surname'  " do
        before(:context) do
          reset_models
          TestModel.is_a_limesurvey_participant(:email_attr => 'email_address', :firstname_attr => 'name', :lastname_attr => 'surname')
        end
        its(:limesurvey_participant_email_attr) { is_expected.to eq 'email_address' }
        its(:limesurvey_participant_firstname_attr) { is_expected.to eq 'name' }
        its(:limesurvey_participant_lastname_attr) { is_expected.to eq 'surname' }
        its(:limesurvey_participant_attribute_1_attr) { is_expected.to eq 'id' }
      end
    end

    context "when participant model is initialized with options: :attribute_1_attr => 'extra_id', :email_attr => 'email_address', :firstname_attr => 'name', :lastname_attr => 'surname'" do
      
      before(:context) { TestModel.is_a_limesurvey_participant(:attribute_1_attr => "extra_id", :email_attr => 'email_address', :firstname_attr => 'name', :lastname_attr => 'surname') }
      
      let(:a_participant) { FactoryGirl.create(:test_model) }

      describe "#add_to_survey(arg)"  do
        context "when arg is an existing survey object" do
          it "returns true" do
            expect(a_participant.add_to_survey(test_survey)).to be true
          end
          context "and #{described_class} instance is already registered" do
            before do
              a_participant.add_to_survey(test_survey)
            end
            it "returns false" do
              expect(a_participant.add_to_survey(test_survey)).to be false
            end
          end
        end
        context "when arg is something wrong" do
          it "raise WrongArgumentError" do
            expect { a_participant.add_to_survey(Object.new) }.to raise_error(WrongArgumentError)
          end
        end
      end
      describe "#remove_from_survey(arg)" do
        context "when arg is an existing survey object" do
          context "when #{described_class} instance is already registered" do
            before do
              a_participant.add_to_survey(test_survey)
            end
            it "returns true" do
              expect(a_participant.remove_from_survey(test_survey)).to be true
            end
          end
          context "when #{described_class} instance is not registered" do
            it "returns false" do
              expect(a_participant.remove_from_survey(test_survey)).to be false
            end
          end
        end
        context "when arg is something wrong" do
          it "raise WrongArgumentError" do
            expect { a_participant.remove_from_survey(Object.new) }.to raise_error(WrongArgumentError)
          end
        end
      end
      describe "#surveys" do
        before(:context) do
          @another_test_survey_id = get_brand_new_test_survey_id(:activate_tokens => true)
          @another_more_test_survey_id = get_brand_new_test_survey_id(:activate_tokens => true)
        end
        let(:another_test_survey) { Survey.find(@another_test_survey_id) }
        let(:another_more_test_survey) { Survey.find(@another_more_test_survey_id) }
        it "returns an empty array" do
          expect(a_participant.surveys).to be_empty
        end
        context "when has added to a survey" do
          before { SurveyParticipation.create!(:survey_id => test_survey.id, :participant_id => a_participant.id ) }
          it "returns an array with one element and that element containing a Survey object" do
            expect(a_participant.surveys.size).to eq 1 and 
            expect(a_participant.surveys.first).to be_kind_of(Survey)
          end
          describe "#survey__ids" do
            it "returns an array with the id of the survey" do
              expect(a_participant.survey__ids.size).to eq 1 and 
              expect(a_participant.survey__ids.first).to eq test_survey.id
            end
          end
          describe "#available_survey__ids" do
            it "returns an array with the id of the remaining surveys" do
              expect(a_participant.available_survey__ids).to match_array [another_more_test_survey.id, another_test_survey.id]
            end
          end
          describe "#available_surveys" do
            it "returns an array with two elements" do
              expect(a_participant.available_surveys.map(&:id)).to match_array [another_more_test_survey.id, another_test_survey.id]
            end
          end
          context "when has added to another survey" do
            before { SurveyParticipation.create(:survey_id => another_test_survey.id, :participant_id => a_participant.id ) }
            it "returns an array with two elements" do
              expect(a_participant.surveys.map(&:id)).to match_array [test_survey.id, another_test_survey.id]
            end
            describe "#survey__ids" do
              it "returns an array with the ids of the two surveys" do
                expect(a_participant.survey__ids).to match_array [test_survey.id, another_test_survey.id]
              end
            end
            describe "#available_survey__ids" do
              it "returns an array with the id of the remaining surveys" do
                expect(a_participant.available_survey__ids).to match_array [another_more_test_survey.id]
              end
            end

          end

        end
      end
    end

    describe "#destroy" do
      before do
        reset_models
        TestModel.is_a_limesurvey_participant(opts)
        test_survey.add_participant!(a_participant)
      end

      context "when participant model is initialized with no options" do
        let(:opts){{}}
        it "limesurvey token doesn't get destroyed" do
          tid = a_participant.survey_participations.for_survey(test_survey.id).token_id
          a_participant.destroy
          expect(LimesurveyRails.list_participants(test_survey.id).map { |p| p["tid"] }).to include(tid)
        end
        it "participation remain but with no reference to the destroyed participant" do
          tid = a_participant.survey_participations.for_survey(test_survey.id).token_id
          a_participant.destroy
          expect(SurveyParticipation.find_by_token_id(tid)).to be_present
        end
      end
      context "when participant model is initialized with option: :dependent_participations => :destroy" do
        let(:opts){{:dependent_participations => :destroy}}
        it "also destroy token on limesurvey" do
          tid = a_participant.survey_participations.for_survey(test_survey.id).token_id
          a_participant.destroy
          expect(LimesurveyRails.list_participants(test_survey.id).map { |p| p["tid"] }).to_not include(tid)
        end
      end
      context "when participant model is initialized with option: :dependent_participations => :restrict", :wip  do
        let(:opts){{:dependent_participations => (Rails.version =~ /^4/ ? :restrict_with_exception : :restrict)}}
        specify { expect { a_participant.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError) }
      end
    end


  end
end

