module LimesurveyRails

  class Survey < NoPersistenceActiveModel

    LIST_SURVEYS_ATTRIBUTES = %w{ sid surveyls_title startdate expires active }

    ALL_ATTRIBUTES = LIST_SURVEYS_ATTRIBUTES.sort.unshift('id')

    attr_accessor *ALL_ATTRIBUTES

    alias_attribute :title, :surveyls_title
    alias_attribute :created_at, :datecreated

    validates_presence_of :surveyls_title
    validates_presence_of :language

    def self.all
      LimesurveyRails.list_surveys.map do |s|
        id = s.delete('sid').to_i
        new({id: id}.merge(s))
      end
    end

    def self.find(survey_id)
      self.all.find{|s| s.id == survey_id.to_i} or raise(RemoteControlError,"Invalid survey ID")
    end

    def self.add(title,lang)
      id = LimesurveyRails.add_survey(nil,title,lang)
      LimesurveyRails.activate_tokens(id,[1])
    end

    def self.new_survey_url
      LimesurveyRails.configuration.base_url + '/admin/survey/sa/newsurvey'
    end

    def self.url_for(survey_id)
      LimesurveyRails.configuration.base_url + "/admin/survey/sa/view/surveyid/#{survey_id}"
    end

    def destroy
      num_rows_to_delete = SurveyParticipation.for_survey(id).size
      LimesurveyRails.delete_survey(id) and num_rows_to_delete == SurveyParticipation.for_survey(id).delete_all
    end

    def active?
      case active
      when 'Y'
        true
      when 'N'
        false
      end
    end

    def status
      active? ? 'active' : 'not active'
    end

    def description
      "#{id} - #{title} [#{status}]"
    end

    # def ==(comparison_object)
    #   comparison_object.equal?(self) ||
    #     (comparison_object.instance_of?(self.class) &&
    #       comparison_object.id == id &&
    #       !comparison_object.new_record?)
    # end

    def url
      Survey.url_for(id)
    end

    def inspect
      "#< #{self.class} id=#{id} title='#{title}' >"
    end

    def to_s
      "#{title} [#{id}]"  
    end

    def participants
      participations = SurveyParticipation.for_survey(id)
      raise InconsistentParticipantsError if participations.map(&:token_id).sort != LimesurveyRails.list_participants(id).map{|p| p['tid']}.sort
      participations.map(&:participant)
    end

    def add_participant!(participant)
      if participant.class.is_a_limesurvey_participant_class?
        SurveyParticipation.create!(:participant_id => participant.id, :survey_id => id)
        return true
      else
        raise WrongArgumentError, "expexted limesurvey participant enabled object, got #{participant.class}"
      end
    end

    def add_participant(participant)
      add_participant!(participant) rescue false
    end

    def remove_participant!(participant)
      if participant.class.is_a_limesurvey_participant_class?
        ss = SurveyParticipation.find_by_participant_id_and_survey_id(participant.id,id)
        ss.destroy
        return true
      else
        raise WrongArgumentError, "expected limesurvey participant enabled object, got #{participant.class}"
      end
    end

    def remove_participant(participant)
      remove_participant!(participant) rescue false
    end

    def invite_participants!
      res = LimesurveyRails.invite_participants(id)
      status = res.delete('status')
      if status.end_with?('No candidate tokens')
        [0,token_count]
      elsif status.end_with?('left to send')
        [res.size, status.split(' ').first.to_i]
      else
        raise
      end
    end

    def reload
      self.class.find(id)
    end

    private

  end

end