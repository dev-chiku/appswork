class CreateConnections < ActiveRecord::Migration
  def change
    create_table :connections, id: false do |t|
      t.column :id, 'BIGINT PRIMARY KEY AUTO_INCREMENT'
      t.integer :connect_kbn
      t.integer :from_user_id, limit: 8
      t.integer :to_user_id, limit: 8
      t.integer :target_id, limit: 8
      t.integer :create_user_id, limit: 8
      t.integer :update_user_id, limit: 8

      t.timestamps null: false
    end
  end
end
