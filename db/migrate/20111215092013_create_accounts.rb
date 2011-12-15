class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do | t |
      t.references :user
      t.string :google_identifier
      t.string :oauth_token
      t.string :refresh_token
      t.string :email
    end

    add_index :accounts, :google_identifier, :unique => true
    add_index :accounts, :email, :unique => true
  end

  def self.down
    drop_table :accounts
  end
end
