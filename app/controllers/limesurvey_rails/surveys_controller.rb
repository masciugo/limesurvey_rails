require_dependency "limesurvey_rails/application_controller"

module LimesurveyRails
  class SurveysController < ApplicationController
    # GET /surveys
    def index
      @surveys = Survey.all
    end
  
    # PUT /surveys/1/invite
    def invite_participants
      @survey = Survey.find(params[:id])
      @survey.invite_participants!
      redirect_to surveys_url
    end

    # GET /surveys/1
    def show
      redirect_to Survey.url_for(params[:id])
    end
  
    # GET /surveys/new
    def new
      @survey = Survey.new
    end
  
    # GET /surveys/1/edit
    def edit
      redirect_to Survey.url_for(params[:id])
    end
  
    # POST /surveys
    def create
      @survey = Survey.new(params[:survey])
      respond_to do |format|
        if @survey.valid? and Survey.add(@survey.title,@survey.language)
          format.html { redirect_to surveys_url, notice: 'Survey was successfully created.' }
        else
          format.html { render action: "new" }
        end
      end
    end
  
    # DELETE /surveys/1
    def destroy
      @survey = Survey.find(params[:id])
      @survey.destroy
      redirect_to surveys_url
    end
  end
end
