require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

module LimesurveyRails
  describe SurveyParticipation, :participation do
    
    subject { SurveyParticipation }

    before(:all) do
      configure_and_connect
      @test_survey_id = get_brand_new_test_survey_id(:activate_tokens => true)
      # reset_models # uncomment to run all suite test in one single run
      TestModel.is_a_limesurvey_participant :attribute_1_attr => "extra_id", :email_attr => 'email_address', :firstname_attr => 'name', :lastname_attr => 'surname'
    end 
    after(:all) { remove_all_test_surveys }

    let(:a_participant) { FactoryGirl.create(:test_model) }
    let(:test_survey) { Survey.find(@test_survey_id) }

    describe ".new" do
      describe "the new SurveyParticipation object" do
        context "when another record with the same survey_id and participant_id exist" do
          before(:each) { SurveyParticipation.create(:survey_id => test_survey.id, :participant_id => a_participant.id ) }
          subject { SurveyParticipation.new(:survey_id => test_survey.id, :participant_id => a_participant.id ) }
          specify do
            subject.valid?
            expect(subject.errors[:participant_id].size).to eq 1
          end
        end
        [:participant_id,:survey_id].each do |a|
          context "when trying to create a new instance without #{a}" do
            subject { SurveyParticipation.new }
            specify do
              subject.valid?
              expect(subject.errors[a].size).to eq 1
            end
          end
        end
        
      end
    end

    describe "callbacks beahvior" do
      # before(:each) { LimesurveyRails.connect }
      let!(:a_participant) { FactoryGirl.create(:test_model) }
      let!(:test_survey) { Survey.find(@test_survey_id) }
      describe "#create!" do
        describe "returned value" do
          subject(:ss) { SurveyParticipation.create!(:survey_id => test_survey.id, :participant_id => a_participant.id ) }
          its(:token){ is_expected.to be_kind_of String }
          its(:token_id){ is_expected.to be_kind_of String }
          its(:url){ is_expected.to eq(LIMESURVEY_BASE_URL + "/survey/index/sid/#{ss.survey_id}/token/#{ss.token}/lang//newtest/Y") }
        end
        context "when something goes wrong with limesurvey add_participants call during the callback" do
          before(:each) { LimesurveyRails.stub(:add_participants).and_raise }
          specify { expect { SurveyParticipation.create!(:survey_id => test_survey.id, :participant_id => a_participant.id ) }.to raise_error}
          it "doesn't create the SurveyParticipation object" do
            SurveyParticipation.create!(:survey_id => test_survey.id, :participant_id => a_participant.id ) rescue nil
            expect(SurveyParticipation.all).to be_empty
          end
        end
        context "when something goes wrong with updating token_id attributes during the callback" do
          before(:each) { SurveyParticipation.any_instance.stub(:save!).and_raise }
          specify { expect { SurveyParticipation.create!(:survey_id => test_survey.id, :participant_id => a_participant.id ) }.to raise_error}
        end
      end
      describe "#destroy!" do
        before(:each) { @ss = SurveyParticipation.create(:survey_id => test_survey.id, :participant_id => a_participant.id ) }
        context "when something goes wrong with limesurvey delete_participants call during the callback" do
          before(:each) { LimesurveyRails.stub(:delete_participants).and_raise }
          specify { expect { @ss.destroy }.to raise_error}
        end
      end
    end

    describe "limesurvey attributes" do
      before(:each) { test_survey.add_participant!(a_participant) }
      let(:a_participant) { FactoryGirl.create(:test_model, :extra_id => "XX030459") }
      let(:ss) { a_participant.survey_participations.for_survey(test_survey.id) }
      ['email', 'firstname', 'lastname'].each do |a|
        it "includes correct value for attribute #{a}" do
          token_value = ss.send(a)
          participant_value = a_participant[TestModel.send("limesurvey_participant_#{a}_attr")]
          expect(token_value).to eq(participant_value)
        end
      end
      it "includes correct value for attribute attribute_1" do
        token_value = ss.attribute_1
        participant_value = a_participant[TestModel.send("limesurvey_participant_attribute_1_attr")]
        expect(token_value).to eq(participant_value)
      end
      it "includes OK as value for emailstatus" do
        token_value = ss.emailstatus
        expect(token_value).to eq('OK')
      end
      context "when email is not available" do
        let(:a_participant) { FactoryGirl.create(:test_model, :email_address => nil) }
        it "includes UNKNOWN as value for emailstatus" do
          token_value = ss.emailstatus
          expect(token_value).to eq('UNKNOWN')
        end
      end
    end

    describe "#survey" do
      let(:a_participation) { SurveyParticipation.create(:survey_id => test_survey.id, :participant_id => a_participant.id ) }
      it "returns the survey" do
        expect(a_participation.survey).to be_a(Survey)
      end
    end

    describe "#to_s", :wip do
      let(:a_participation) { SurveyParticipation.create(:survey_id => test_survey.id, :participant_id => a_participant.id ) }
      it "returns a short description" do
        expect(a_participation.to_s).to eq "#{a_participant} (#{test_survey})"
      end
    end

  end
end

