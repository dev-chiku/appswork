class CreateItemProposes < ActiveRecord::Migration
  def change
    create_table :item_proposes, id: false do |t|
      t.column :id, 'BIGINT PRIMARY KEY AUTO_INCREMENT'
      t.integer :item_id, limit: 8
      t.integer :payment_kbn
      t.integer :price, limit: 8
      t.date :noki
      t.integer :hour_price
      t.integer :week_hour_kbn
      t.integer :week_hour_period_kbn
      t.string :content
      t.integer :ok_flg
      t.integer :create_user_id, limit: 8
      t.integer :update_user_id, limit: 8

      t.timestamps null: false
    end
  end
end
