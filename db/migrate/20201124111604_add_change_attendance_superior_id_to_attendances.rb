class AddChangeAttendanceSuperiorIdToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change_attendance_superior_id, :integer, comment: '勤怠変更申請上長id選択'
  end
end
