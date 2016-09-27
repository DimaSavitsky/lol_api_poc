class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :summoner_name
      t.string :summoner_id

      t.string :region

      t.timestamps
    end
  end
end
