# This migration comes from limesurvey_rails (originally 20140130110450)
class CreateLimesurveyRailsSurveyParticipations < ActiveRecord::Migration
  def change
    create_table :limesurvey_rails_survey_participations do |t|
      t.integer :participant_id
      t.integer :survey_id
      t.string :token_id
      t.string :token
      t.timestamps
    end
  end
end
