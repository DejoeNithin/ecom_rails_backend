class RenameSku < ActiveRecord::Migration[6.0]
  def change
    rename_table :skus, :skunit
  end
end
