module LimesurveyRails
  
  module Participant

    extend ActiveSupport::Concern

    included do
      # I put this here because I want limesurvey_participant class attribute to be available as soon as you include the gem
      class_attribute :limesurvey_participant
      self.limesurvey_participant = false
      # instance methods
      def add_to_survey(survey)
        if survey.is_a? Survey
          survey.add_participant(self)
        else
          raise WrongArgumentError, "expexted Survey object, got #{survey.class}"
        end
      end

      def remove_from_survey(survey)
        if survey.is_a? Survey
          survey.remove_participant(self)
        else
          raise WrongArgumentError, "expexted Survey object, got #{survey.class}"
        end
      end

      def surveys
        survey_participations.map(&:survey)
      end

      def available_surveys
        ids = surveys.map(&:id).map(&:to_s)
        Survey.all.delete_if{|s| ids.include? s.id }
      end

    end

    module ClassMethods
      
      def is_a_limesurvey_participant(opts = {})
        # puts "################################ init #{self} as a limesurvey_participant with opts #{opts}"
        self.limesurvey_participant = true

        # check options
        opts.keys.each{|k| raise WrongArgumentError unless [:attribute_1_attr, :email_attr, :firstname_attr, :lastname_attr, :dependent_participations].include? k}

        {:attribute_1_attr => 'id', :email_attr => nil, :firstname_attr => nil, :lastname_attr => nil, :dependent_participations => :nullify }.each do |k,v|
          class_attribute_name = "limesurvey_participant_#{k}"
          class_attribute class_attribute_name
          self.send("#{class_attribute_name}=", (opts[k] or v))
        end

        has_many :survey_participations, :class_name => "LimesurveyRails::SurveyParticipation", :foreign_key => "participant_id", :dependent => limesurvey_participant_dependent_participations  do
          def for_survey(survey_id)
            res = where("survey_id = #{survey_id}")
            raise MultipleParticipationsToSurveyError if res.size > 1
            res.first
          end
        end

        LimesurveyRails::SurveyParticipation.class_exec(self){ |klass| belongs_to :participant, :class_name => klass, :foreign_key => 'participant_id'}
        # LimesurveyRails::SurveyParticipation.belongs_to :participant, :class_name => self.name, :foreign_key => 'participant_id' 

        # to make sure LimesurveyRails::SurveyParticipation model is connected to the same database of the is_a_limesurvey_participant class (in case of multi database apps)
        LimesurveyRails::SurveyParticipation.establish_connection(connection_config) unless Rails.env.test? #... but during test it creates problems because SQLite only allow one connection 
        
        # below the proof that among tests associated classes not get updated even after remove_const calls
        # see also http://code.activestate.com/lists/ruby-talk/42730/
        # puts (LimesurveyRails::SurveyParticipation.reflect_on_association(:participant).klass.object_id == self.object_id)

      end

      def is_a_limesurvey_participant_class?
        limesurvey_participant
      end
    end
      
  end

  ActiveRecord::Base.send :include, Participant

end

