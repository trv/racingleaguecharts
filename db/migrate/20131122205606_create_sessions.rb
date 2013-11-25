class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.string :token
      t.float :type

      t.timestamps
    end
  end
end
