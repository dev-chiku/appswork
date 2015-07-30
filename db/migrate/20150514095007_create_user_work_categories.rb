class CreateUserWorkCategories < ActiveRecord::Migration
  def change
    create_table :user_work_categories, id: false do |t|
      t.column :id, 'BIGINT PRIMARY KEY AUTO_INCREMENT'
      t.integer :user_id, limit: 8
      t.integer :name_id, limit: 8
      t.integer :create_user_id, limit: 8
      t.integer :update_user_id, limit: 8

      t.timestamps null: false
    end
  end
end
