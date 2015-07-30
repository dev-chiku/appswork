class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages, id: false do |t|
      t.column :id, 'BIGINT PRIMARY KEY AUTO_INCREMENT'
      t.integer :item_id, limit: 8
      t.integer :parent_id
      t.integer :send_user_id, limit: 8
      t.integer :receive_user_id, limit: 8
      t.string :title
      t.string :content
      t.integer :create_user_id, limit: 8
      t.integer :update_user_id, limit: 8

      t.timestamps null: false
    end
  end
end
