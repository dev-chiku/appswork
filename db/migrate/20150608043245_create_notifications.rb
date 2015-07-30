class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications, id: false do |t|
      t.column :id, 'BIGINT PRIMARY KEY AUTO_INCREMENT'
      t.integer :notification_kbn
      t.integer :target_id, limit: 8
      t.integer :user_id, limit: 8
      t.integer :create_user_id, limit: 8
      t.integer :update_user_id, limit: 8

      t.timestamps null: false
    end
  end
end
