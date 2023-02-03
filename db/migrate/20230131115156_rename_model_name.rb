class RenameModelName < ActiveRecord::Migration[6.0]
  def change
    rename_column :skunits, :model_name, :modelName
  end
end
