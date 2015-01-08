module LimesurveyRails
  class SurveyParticipation < ActiveRecord::Base

    GET_PARTICIPANT_PROPERTY_ATTRIBUTES = %w{ attribute_1 tid completed language usesleft firstname blacklisted validfrom lastname sent validuntil email remindersent mpid emailstatus remindercount  }

    attr_accessible :participant_id, :survey_id
    attr_accessor *GET_PARTICIPANT_PROPERTY_ATTRIBUTES

    validates :participant_id, :uniqueness => {:scope => :survey_id}

    validates_presence_of [:participant_id, :survey_id]
    validates_presence_of :token, :on => :update

    scope :for_survey, lambda { |survey_id| where(:survey_id => survey_id) }

    after_initialize :assign_ls_token_attributes, :unless => 'new_record?' 
    after_create :add_token_to_limesurvey
    after_destroy :delete_token_from_limesurvey

    def url
      LimesurveyRails.configuration.base_url + "/survey/index/sid/#{survey_id}/token/#{token}/lang//newtest/Y"
    end

    def survey
      Survey.find(survey_id)
    end

    %w{ completed sent }.each do |name|
      define_method "#{name}?" do
        case send(name)
        when 'Y'
          true
        when 'N'
          false
        else
          true
        end
      end
    end
    
    def to_s
      "#{participant} (#{survey})"
    end

    private

    def assign_ls_token_attributes
      begin
        LimesurveyRails.get_participant_properties(survey_id,token_id,GET_PARTICIPANT_PROPERTY_ATTRIBUTES).each{ |a,v| self.send("#{a}=",v)}
      rescue RemoteControlError => e
        if e.message.end_with? 'Invalid tokenid'
          raise InconsistentParticipantsError, "Participation #{self} was not found on Limesurvey"
        else
          raise e
        end
      end
    end

    def add_token_to_limesurvey
      opts = [:email, :firstname, :lastname, :attribute_1].inject({}) do |h,a|
        method = participant.class.send("limesurvey_participant_#{a}_attr")
        if method and participant.respond_to? method
          h.merge(a => participant.send(method))
        else
          h
        end
      end
      opts.merge!(:emailstatus => (opts[:email].nil? ? 'UNKNOWN' : 'OK') )

      res = LimesurveyRails.add_participants(survey_id,[opts],true)
      self.token_id = res.first['tid']
      self.token = res.first['token']
      save!
    end

    def delete_token_from_limesurvey
      res = LimesurveyRails.delete_participants(survey_id,[token_id])
      raise RemoteControlError, "something went wrong while deleting participant #{token_id} on survey #{survey_id}" unless res.keys == [token_id]
    end

  end
end
