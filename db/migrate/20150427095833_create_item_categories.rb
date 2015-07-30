class CreateItemCategories < ActiveRecord::Migration
  def change
    create_table :item_categories, id: false do |t|
      t.column :id, 'BIGINT PRIMARY KEY AUTO_INCREMENT'
      t.integer :item_id, limit: 8, :null => false
      t.integer :category_id, limit: 8, :null => false
      t.integer :create_user_id, limit: 8
      t.integer :update_user_id, limit: 8

      t.timestamps null: false
    end
  end
end
