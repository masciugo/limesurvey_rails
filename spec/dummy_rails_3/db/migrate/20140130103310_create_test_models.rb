class CreateTestModels < ActiveRecord::Migration
  def change
    create_table :test_models do |t|
      t.string :name
      t.string :surname
      t.string :email_address
      t.string :extra_id

      t.timestamps
    end
  end
end
