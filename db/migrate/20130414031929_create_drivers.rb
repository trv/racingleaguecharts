class CreateDrivers < ActiveRecord::Migration
  def change
    create_table :drivers do |t|
      t.string :name
      t.integer :team_id

      t.timestamps
    end
  end
end
