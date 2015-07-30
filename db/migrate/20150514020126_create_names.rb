class CreateNames < ActiveRecord::Migration
  def change
    create_table :names do |t|
      t.integer :name_kbn
      t.integer :parent_id
      t.string :name
      t.integer :create_user_id, limit: 8
      t.integer :update_user_id, limit: 8

      t.timestamps null: false
    end
  end
end
