module LimesurveyRails
  class GenericError < StandardError; end
  class RemoteControlError < GenericError;  end
  class WrongArgumentError < GenericError;  end
  class InconsistentParticipantsError < GenericError;  end
  class MultipleParticipationsToSurveyError < GenericError;  end
end