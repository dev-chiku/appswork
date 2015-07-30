class CreateItemComments < ActiveRecord::Migration
  def change
    create_table :item_comments, id: false do |t|
      t.column :id, 'BIGINT PRIMARY KEY AUTO_INCREMENT'
      t.integer :item_id, limit: 8
      t.string :comment
      t.integer :create_user_id, limit: 8
      t.integer :update_user_id, limit: 8

      t.timestamps null: false
    end
  end
end
