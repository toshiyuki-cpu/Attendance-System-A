class AddIndexToBasesBaseNumber < ActiveRecord::Migration[5.1]
  def change
    add_index :bases, :base_number, unique: true
  end
end
