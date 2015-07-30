class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users, id: false do |t|
      t.column :id, 'BIGINT PRIMARY KEY AUTO_INCREMENT'
      t.string :unique_id
      t.string :email
      t.string :password
      t.integer :email_auth_flg
      t.string :display_name
      t.string :content
      t.string :img_path
      t.string :email_token
      t.integer :user_kbn
      t.integer :sex
      t.date :birthday
      t.integer :area
      t.integer :create_user_id, limit: 8
      t.integer :update_user_id, limit: 8

      t.timestamps null: false
    end
  end
end
