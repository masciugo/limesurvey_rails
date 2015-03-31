module LimesurveyRails
  class NoPersistenceActiveModel
    include ActiveModel::MassAssignmentSecurity if Rails.version =~ /^3/
    include ActiveModel::Validations  
    include ActiveModel::Conversion  
    include ActiveModel::AttributeMethods
    extend ActiveModel::Naming  
    
    # http://stackoverflow.com/questions/8835215/how-to-handle-translations-for-an-activemodel
    class << self
      def i18n_scope
        :activerecord
      end
    end

    def initialize(params = {})  
      params.each do |name, value|  
        send("#{name}=", value)  
      end  
    end

    def persisted?  
      false  
    end 

    # http://api.rubyonrails.org/classes/ActiveModel/AttributeMethods.html
    def attributes
      if defined?(self.class::ALL_ATTRIBUTES)
        self.class::ALL_ATTRIBUTES.inject({}){|memo,a| memo.merge( a => send(a) )}
      end
    end
  end
end
