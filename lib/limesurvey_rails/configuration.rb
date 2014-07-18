module LimesurveyRails

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  def self.configured?
    !(configuration and configuration.api_url and configuration.username and configuration.password).blank?
  end

  class Configuration
    attr_accessor :api_url, :username, :password, :auto_connection, :max_number_of_tokens_per_survey

    def initialize
      @api_url = nil
      @username = nil
      @password = nil
      @auto_connection = false
      @max_number_of_tokens_per_survey = 100000
    end

    def base_url
      @api_url.gsub('/admin/remotecontrol','')
    end
  end
end