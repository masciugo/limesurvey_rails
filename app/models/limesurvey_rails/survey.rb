module LimesurveyRails

  class Survey < NoPersistenceActiveModel

    LIST_SURVEYS_ATTRIBUTES = %w{ sid surveyls_title startdate expires active }

    GET_SUMMARY_RESPONSES_ATTRIBUTES = %w{ completed_responses incomplete_responses full_responses }
    GET_SUMMARY_TOKENS_ATTRIBUTES = %w{ token_count token_invalid token_sent token_opted_out token_completed }
    GET_SUMMARY_ATTRIBUTES = GET_SUMMARY_RESPONSES_ATTRIBUTES + GET_SUMMARY_TOKENS_ATTRIBUTES
    GET_SURVEY_PROPERTY_ATTRIBUTES = %w{ attributedescriptions savetimings allowprev tokenanswerspersistence showgroupinfo showwelcome owner_id template printanswers assessments shownoanswer showprogress admin language ipaddr usecaptcha showqnumcode allowjumps active additional_languages refurl usetokens bouncetime navigationdelay expires datestamp datecreated bounce_email bounceprocessing nokeyboard startdate usecookie publicstatistics bounceaccounttype alloweditaftercompletion adminemail allowregister publicgraphs emailresponseto bounceaccounthost googleanalyticsstyle anonymized allowsave listpublic emailnotificationto bounceaccountpass googleanalyticsapikey faxto autonumber_start htmlemail tokenlength bounceaccountencryption format autoredirect sendconfirmation showxquestions bounceaccountuser }
    GET_LANGUAGE_PROPERTIES_ATTRIBUTES = %w{ surveyls_survey_id surveyls_url surveyls_email_register_subj email_admin_notification_subj surveyls_language surveyls_urldescription surveyls_email_register email_admin_notification surveyls_title surveyls_email_invite_subj surveyls_email_confirm_subj email_admin_responses_subj surveyls_description surveyls_email_invite surveyls_email_confirm email_admin_responses surveyls_welcometext surveyls_email_remind_subj surveyls_dateformat surveyls_numberformat surveyls_endtext surveyls_email_remind surveyls_attributecaptions }
    
    ALL_ATTRIBUTES = (GET_SUMMARY_ATTRIBUTES | GET_SURVEY_PROPERTY_ATTRIBUTES | GET_LANGUAGE_PROPERTIES_ATTRIBUTES ).sort.unshift('id')

    attr_accessor *ALL_ATTRIBUTES

    alias_attribute :title, :surveyls_title
    alias_attribute :created_at, :datecreated

    validates_presence_of :surveyls_title
    validates_presence_of :language

    def self.all(lang = nil)
      LimesurveyRails.list_surveys(LimesurveyRails.configuration.username).map{|s| build(s['sid'],lang) }
    end

    def self.find(survey_id,lang = nil)
      build(survey_id,lang)
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
      Survey.build(id)
    end

    private

    def self.build(survey_id, lang = nil)
      all_attributes = {id: survey_id.to_i}
      all_attributes.merge!(LimesurveyRails.get_survey_properties(survey_id,GET_SURVEY_PROPERTY_ATTRIBUTES))
      
      # if all_attributes['active'] == 'Y'
        all_attributes.merge!(LimesurveyRails.get_summary(survey_id,'all')) 
      # else
      #   GET_SUMMARY_TOKENS_ATTRIBUTES.each{|a| all_attributes[a] = LimesurveyRails.get_summary(survey_id,a) rescue nil }
      # end
      all_attributes.merge!(LimesurveyRails.get_language_properties(survey_id,GET_LANGUAGE_PROPERTIES_ATTRIBUTES,lang || all_attributes['language']))
      new(all_attributes)
    end

  end

end