class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do | t|
      t.string :firstname
      t.string :lastname
    end
  end

  def self.down
    drop_table :users
  end
end
