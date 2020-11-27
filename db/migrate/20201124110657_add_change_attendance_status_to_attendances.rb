class AddChangeAttendanceStatusToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change_attendance_status, :string, comment: '勤怠変更申請状態(申請中、承認、否認、なし)'
  end
end
