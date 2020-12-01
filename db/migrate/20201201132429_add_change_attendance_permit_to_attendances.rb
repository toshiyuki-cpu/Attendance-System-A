class AddChangeAttendancePermitToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change_attendance_permit, :boolean, comment: '勤怠変更送信許可のチェック'
  end
end
