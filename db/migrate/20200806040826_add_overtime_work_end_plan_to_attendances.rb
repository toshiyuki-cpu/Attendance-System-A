class AddOvertimeWorkEndPlanToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overtime_work_end_plan, :datetime
  end
end
