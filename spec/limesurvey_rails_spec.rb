require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe LimesurveyRails, :main => true do
  after(:each) do
    LimesurveyRails.reset
  end

  context "when it's not fully configured" do
    before(:each) { LimesurveyRails.reset }
    its(:configured?) { is_expected.to be false }
    its(:connected?) { is_expected.to be false }
  end

  context "when it's configured with a wrong password" do
    before(:each) do
      LimesurveyRails.configure do |config|
        config.api_url = LIMESURVEY_API_URL
        config.username = LIMESURVEY_USERNAME
        config.password = 'wrong_password'
      end
    end
    describe ".connect" do
      it "return false" do
        expect(LimesurveyRails.connect).to be false
      end
    end
  end

  context "when it's fully configured" do
    before(:each) do
      LimesurveyRails.configure do |config|
        config.api_url = LIMESURVEY_API_URL
        config.username = LIMESURVEY_USERNAME
        config.password = LIMESURVEY_PASSWORD
      end
    end
    its(:configured?) {is_expected.to be true }
    describe 'LimesurveyRails.configuration' do
      subject { LimesurveyRails.configuration }
      its(:username) {should eq(LIMESURVEY_USERNAME) }
      its(:password) {should eq(LIMESURVEY_PASSWORD) }
      its(:base_url) {should eq(LIMESURVEY_BASE_URL) }
    end
    its(:connected?) { is_expected.to be false }
    describe ".connect" do
      it "return true" do
        expect(LimesurveyRails.connect).to be true
      end
    end
    describe ".disconnect" do
      it "return true" do
        expect(LimesurveyRails.disconnect).to be false
      end
    end
    context "when it's connected" do
      before(:each) do
        LimesurveyRails.connect
      end
      describe ".connect" do
        it "return false" do
          expect(LimesurveyRails.connect).to be false
        end
      end
      describe ".connect(true)" do
        it "return true" do
          expect(LimesurveyRails.connect(true)).to be true
        end
      end
      its(:connected?) { is_expected.to be true }
      describe ".disconnect" do
        it "return true" do
          expect(LimesurveyRails.disconnect).to be true
        end
      end
      describe ".list_surveys" do
        it "return an array" do
          expect(LimesurveyRails.list_surveys).to be_an_instance_of Array
        end
      end
      describe ".wrong_name_method" do
        specify { expect { LimesurveyRails.wrong_name_method }.to raise_error }
      end
      context "when it's session key becomes invalid/expired" do
        before(:each) do
          LimesurveyRails.session_key = 'wrong_session_key'
        end
        its(:connected?) { is_expected.to be true }
        describe ".connected?(true)" do
          specify { expect(LimesurveyRails.connected?(true)).to be false }
        end
        it "raise RemoteControlError claiming Invalid session key" do
          expect { LimesurveyRails.list_surveys }.to raise_error(LimesurveyRails::RemoteControlError, /Invalid session key$/)
        end
      end
    end
    context "when it's configurated with continuous connection" do
      before(:each) do
        LimesurveyRails.configure do |config|
          config.auto_connection = true
        end
      end
      its(:connected?) { is_expected.to be false }
      describe ".connected?(true)" do
        specify { expect(LimesurveyRails.connected?(true)).to be false }
      end
      context "when it is connected" do
        before(:each) do
          LimesurveyRails.connect
        end
        its(:connected?) { is_expected.to be true }
        describe ".connected?(true)" do
          specify { expect(LimesurveyRails.connected?(true)).to be true }
        end
        context "when it's session key becomes invalid/expired" do
          before(:each) do
            LimesurveyRails.session_key = 'wrong_session_key'
          end
          its(:connected?) { is_expected.to be true }
          describe ".connected?(true)" do
            specify { expect(LimesurveyRails.connected?(true)).to be false }
          end
          describe ".list_surveys" do
            it "returns a correct result and LimesurveyRails gets a new session_key after reconnecting" do
              expect(LimesurveyRails.list_surveys).to be_an(Array) and
              expect(LimesurveyRails.session_key).not_to eq('wrong_session_key') and
              expect(LimesurveyRails.connected?(true)).to be true
            end
          end
        end
      end
    end
  end




end