class AddDeletedToItems < ActiveRecord::Migration
  def self.up
     change_table :items do |t|
       t.boolean :deleted, :default => false
     end
  end

  def self.down
  end
end
