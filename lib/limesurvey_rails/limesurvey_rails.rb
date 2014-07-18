module LimesurveyRails
  API_METHODS = %w{get_session_key release_session_key get_site_settings add_survey delete_survey import_survey get_survey_properties set_survey_properties list_surveys activate_survey export_statistics get_summary add_language delete_survey_language get_language_properties set_language_properties add_group delete_group import_group get_group_properties set_group_properties list_groups list_users delete_question import_question get_question_properties set_question_properties list_questions activate_tokens add_participants delete_participants get_participant_properties set_participant_properties list_participants activate_tokens invite_participants remind_participants add_response export_responses export_responses_by_token}

  class << self
    attr_accessor :api, :session_key
  end

  def self.connect(force = false)
    if !force and connected?
      false
    else
      if configured?
        self.api = Limesurvey::API.new(configuration.api_url)
        self.session_key = api.get_session_key(configuration.username,configuration.password) if api
      end
      session_key.present? and session_key.is_a? String
    end
  end

  def self.disconnect
    if connected?
      api.release_session_key if api
      self.api = nil
      self.session_key = nil
      api.nil? and session_key.nil?
    else
      false
    end
  end

  def self.connected?
    begin
      raise unless configured?
      raise unless session_key.present?
      check_result = api.list_surveys(session_key)
      raise unless check_result.is_a? Array or check_result['status'] == 'No surveys found'
      true
    rescue Exception => e
      if configuration.try(:auto_connection)
        connect(true)
      else
        false
      end
    end
  end

  def self.reset
    disconnect
    self.configuration = nil
  end

  def self.method_missing(method_name, *arguments, &block)
    if API_METHODS.include? method_name.to_s
      if connected?
        # t0=Time.now
        result = api.send(method_name, *arguments.unshift(session_key))
        # puts "#{method_name} in #{Time.now-t0}"
        if result.is_a? Hash and result["status"] # get exception result
          case result["status"]
          when 'OK'
            true
          when 'No surveys found'
            []
          when 'No Tokens found'
            []
          when /(left to send)|(No candidate tokens)$/
            result # get regular result
          else
            raise RemoteControlError, "#{method_name} returned a failure response status: #{result["status"]}"
          end
        else # get regular result
          result
        end
      else
        raise RemoteControlError, 'you are disconnected from Limesurvey'
      end
    else
      super
    end
  end

  def self.respond_to_missing?(method_name, include_private = false)
    API_METHODS.include? method_name.to_s || super
  end  

end