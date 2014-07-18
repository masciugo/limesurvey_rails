LimesurveyRails::Engine.routes.draw do
  scope "(:locale)", :locale => /#{I18n.available_locales.join("|")}/ do
    resources :surveys do
      put 'invite_participants', :on => :member
    end
  end
end
