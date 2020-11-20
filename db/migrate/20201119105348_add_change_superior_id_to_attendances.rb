class AddChangeSuperiorIdToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change_superior_id, :integer
  end
end
