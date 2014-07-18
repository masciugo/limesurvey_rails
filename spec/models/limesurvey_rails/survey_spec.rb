require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

module LimesurveyRails

  describe Survey, :survey => true do
    before(:all) do
      configure_and_connect
      reset_models
      TestModel.is_a_limesurvey_participant :attribute_1_attr => "extra_id", :email_attr => 'email_address', :firstname_attr => 'name', :lastname_attr => 'surname'
    end
    after(:all) { remove_all_test_surveys }

    describe ".add(title,lang)" do
      it "returns true" do
        expect(Survey.add('test title','en')).to be true
      end
      context "when wrong arguments provided" do
        specify { expect { Survey.add('','en') }.to raise_error RemoteControlError }
        specify { expect { Survey.add('test title','cds') }.to raise_error RemoteControlError }
      end
    end

    describe ".all" do
      before(:each) { remove_all_test_surveys }
      it "returns an empty array" do
        expect(Survey.all).to be_empty
      end
      context "when 3 surveys are present in the db" do
        before(:each) { 3.times{|i| Survey.add("test survey number #{i}",'en') } }
        it "returns an Array" do
          expect(Survey.all).to be_an_instance_of(Array)
        end
        it "returns an Array with 3 elements" do
          expect(Survey.all.size).to be 3
        end
        it "returns an Array made of Survey object" do
          expect(Survey.all.inject(true){|memo,e| memo &= e.is_a? Survey}).to be true
        end
      end
    end

    context "when a test survey is present in the database" do

      before(:each) { remove_all_test_surveys; @test_survey_id = get_brand_new_test_survey_id(:activate_tokens => true) }
    
      let(:test_survey) { Survey.find(@test_survey_id) }

      describe ".find(id)" do
        context "when id is the test survey id"  do
          subject(:res) { Survey.find(@test_survey_id) } 
          it { should be_instance_of Survey }
          it { should have_same_attributes_as test_survey }
        end
        context "when id is wrong" do
          it "raise RemoteControlError with message containing 'Invalid survey ID'" do
            expect { Survey.find(0) }.to raise_error(RemoteControlError, /Invalid survey ID/)
          end
        end
      end

      describe ".url_for(id)" do
        it "returns the specified limesurvey survey url" do
          expect(Survey.url_for(@test_survey_id)).to eq(LIMESURVEY_BASE_URL + "/admin/survey/sa/view/surveyid/#{test_survey.id}")
        end
      end
      
      describe ".new_survey_url" do
        specify { expect(Survey.new_survey_url).to eq(LIMESURVEY_BASE_URL + '/admin/survey/sa/newsurvey') }
      end
      
      describe "#url" do
        it "returns the limesurvey survey url" do
          expect(test_survey.url).to eq(LIMESURVEY_BASE_URL + "/admin/survey/sa/view/surveyid/#{test_survey.id}")
        end
      end

      describe "#description" do
        it "returns a string with id title and status" do
          expect(test_survey.description).to match /#{test_survey.id}.*#{test_survey.title}.*#{test_survey.status}/
        end
      end

      describe "#destroy" do
        it "returns true" do
          expect(test_survey.destroy).to be true
        end
        context "when the survey has participants" do
          # before(:all) { reset_models; TestModel.is_a_limesurvey_participant }
          before(:each) do
            FactoryGirl.create_list(:test_model,3)
            TestModel.all.each{ |tm| FactoryGirl.create(:limesurvey_rails_survey_participation, :survey_id => test_survey.id, :participant_id => tm.id ) }
          end
          it "its survey participations are deleted" do
            test_survey.destroy
            expect(SurveyParticipation.for_survey(test_survey.id)).to be_empty
          end
        end
      end

      describe "participants instance methods"  do
        # before(:all) { reset_models; TestModel.is_a_limesurvey_participant :attribute_1_attr => "extra_id", :email_attr => 'email_address', :firstname_attr => 'name', :lastname_attr => 'surname'}
        # before(:each) do
        #   instances = FactoryGirl.create_list(:test_model,3)
        #   instances.each{ |tm| FactoryGirl.create(:limesurvey_rails_survey_participation, :survey_id => test_survey.id, :participant_id => tm.id ) }
        # end

        let(:a_participant) { FactoryGirl.create(:test_model) }

        describe "#add_participant!(a_participant)" do
          it_should_behave_like "adding a participant", 'add_participant!'
          context "when a_participant is already registered" do
            before(:each) do
              test_survey.add_participant!(a_participant)
            end
            it "raise ActiveRecord::RecordInvalid" do
              expect { test_survey.add_participant!(a_participant) }.to raise_error(ActiveRecord::RecordInvalid)
            end
          end
          context "when a_participant is a regular ActiveRecord::Base object" do
            it "raise WrongArgumentError" do
              expect { test_survey.add_participant!(SurveyParticipation.new) }.to raise_error(WrongArgumentError)
            end
          end
        end
        
        describe "#add_participant(a_participant)" do
          it_should_behave_like "adding a participant", 'add_participant'
          context "when a_participant is already registered" do
            before(:each) do
              test_survey.add_participant(a_participant)
            end
            it "returns false" do
              expect(test_survey.add_participant(a_participant)).to be false
            end
          end
          context "when a_participant is a regular ActiveRecord::Base object" do
            it "returns false" do
              expect(test_survey.add_participant(SurveyParticipation.new)).to be false
            end
          end
        end

        describe "#remove_participant!(a_participant)" do
          it_should_behave_like "removing a participant", 'remove_participant!'
          context "when a_participant is not registered" do
            it "raise NoMethodError" do
              expect { test_survey.remove_participant!(a_participant) }.to raise_error(NoMethodError)
            end
          end
          context "when a_participant is a regular ActiveRecord::Base object" do
            it "raise WrongArgumentError" do
              expect { test_survey.remove_participant!(SurveyParticipation.new) }.to raise_error(WrongArgumentError)
            end
          end
        end
        
        describe "#remove_participant(a_participant)" do
          it_should_behave_like "removing a participant", 'remove_participant'
          context "when a_participant is not registered" do
            it "returns false" do
              expect(test_survey.remove_participant(a_participant)).to be false
            end
          end
          context "when a_participant is a regular ActiveRecord::Base object" do
            it "returns false" do
              expect(test_survey.remove_participant(SurveyParticipation.new)).to be false
            end
          end
        end

        context "when 3 participants are registered" do
          describe "#participants" do
            before(:each) do
              instances = FactoryGirl.create_list(:test_model,3)
              instances.each{ |tm| FactoryGirl.create(:limesurvey_rails_survey_participation, :survey_id => test_survey.id, :participant_id => tm.id ) }
            end
            subject { test_survey.reload }
            its(:participants) { is_expected.to match_ar_array TestModel.all}
            context "when a participant is missinig on Limesurvey" do
              before(:each) do
                id_to_delete = LimesurveyRails.list_participants(test_survey.id).sample['tid']
                LimesurveyRails.delete_participants(test_survey.id,[id_to_delete])
              end
              specify { expect { test_survey.participants }.to raise_error(InconsistentParticipantsError) }
            end
          end
        end

        describe "#invite_participants!" do
          context "when 3 participants are registered with email defined" do
            before(:each) do
              instances = FactoryGirl.create_list(:test_model,3)
              instances.each{ |tm| FactoryGirl.create(:limesurvey_rails_survey_participation, :survey_id => test_survey.id, :participant_id => tm.id ) }
            end
            it "returns array [3,0]" do
              expect(test_survey.invite_participants!).to eq [3,0]
            end
          end
          context "when email is missing for one of them" do
            before(:each) do
              instances = FactoryGirl.create_list(:test_model,2)
              instances << FactoryGirl.create(:test_model,:email_address => nil)
              instances.each{ |tm| FactoryGirl.create(:limesurvey_rails_survey_participation, :survey_id => test_survey.id, :participant_id => tm.id ) }
            end
            it "returns array [2,0]" do
              expect(test_survey.invite_participants!).to eq [2,0]
            end
            describe "survey"  do
              before(:each) { test_survey.invite_participants! }
              subject { test_survey.reload }
              its(:token_count) { is_expected.to eq '3' }
              its(:token_sent) { is_expected.to eq '2' }
            end
          end
        end

      end

    end
  end
end

