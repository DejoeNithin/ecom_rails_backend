class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.integer :sub_category_id
      t.string :product_name
      t.string :description
      t.string :brand_name

      t.timestamps
    end
  end
end
