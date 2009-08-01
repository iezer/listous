class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.string :author
      t.string :text
      t.string :fullMessage
      t.date :submitted
      t.references :list

      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
