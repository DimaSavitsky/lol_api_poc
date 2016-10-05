class CreateSmiteApiSessionsStorage < ActiveRecord::Migration[5.0]
  def change
    create_table :smite_sessions do |t|
      t.string :session_id
      t.datetime :created_at
    end
  end
end