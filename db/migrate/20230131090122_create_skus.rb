class CreateSkus < ActiveRecord::Migration[6.0]
  def change
    create_table :skus do |t|
      t.integer :product_id
      t.string :model_name
      t.string :img_url
      t.integer :stock
      t.float :price

      t.timestamps
    end
  end
end
