class CreateAttributes < ActiveRecord::Migration[6.0]
  def change
    create_table :attributes, :id => false do |t|
      t.integer :sku_id
      t.string :attribute_name
      t.string :attribute_value

      t.timestamps
    end
  end
end
