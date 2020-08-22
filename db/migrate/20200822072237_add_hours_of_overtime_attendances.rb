class AddHoursOfOvertimeAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :hours_of_overtime, :string
  end
end
