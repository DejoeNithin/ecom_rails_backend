class CreateTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :tokens, :id => false do |t|
      t.integer :user_id
      t.string :token
      t.datetime :refresh_time
      t.datetime :expiry_time

      t.timestamps
    end
  end
end
