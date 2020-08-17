class AddSelectSuperiorIdToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :select_superior_id, :integer
  end
end
