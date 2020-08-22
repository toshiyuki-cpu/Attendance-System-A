class RemoveHoursOfOvertimeFromAttendances < ActiveRecord::Migration[5.1]
  def change
    remove_column :attendances, :hours_of_overtime, :string
  end
end
