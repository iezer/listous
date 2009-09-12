class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.integer :twitter_id
      t.integer :last_mention
      t.integer :last_dm
      t.boolean :welcomed, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
