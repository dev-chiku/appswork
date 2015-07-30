class CreateItems < ActiveRecord::Migration
  def change
    create_table :items, id: false do |t|
      t.column :id, 'BIGINT PRIMARY KEY AUTO_INCREMENT'
      t.integer :work_kbn
      t.integer :payment_kbn
      t.integer :price, limit: 8
      t.date :noki
      t.integer :hour_price_kbn
      t.integer :week_hour_kbn
      t.integer :week_hour_period_kbn
      t.date :limit_date
      t.string :title
      t.text :content
      t.string :img_path
      t.string :img_file_name
      t.integer :propose_count, limit: 8
      t.integer :view_count, limit: 8
      t.integer :favorite_count, limit: 8
      t.integer :preview_flg
      t.integer :create_user_id, limit: 8
      t.integer :update_user_id, limit: 8

      t.timestamps null: false
    end
  end
end
