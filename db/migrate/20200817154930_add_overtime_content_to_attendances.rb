class AddOvertimeContentToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overtime_content, :string
  end
end
