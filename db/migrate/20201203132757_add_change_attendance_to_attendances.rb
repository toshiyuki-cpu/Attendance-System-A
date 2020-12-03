class AddChangeAttendanceToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change_started_at, :datetime, comment: '変更後の出勤時間'
    add_column :attendances, :change_finished_at, :datetime, comment: '変更後の退社時間'
    add_column :attendances, :change_note, :string, comment: '変更後の内容'
    add_column :attendances, :change_attendance_superior_id, :integer, comment: '勤怠変更申請上長id選択'
    add_column :attendances, :change_attendance_status, :string, comment: '勤怠変更申請状態(申請中、承認、否認、なし)'
    add_column :attendances, :change_attendance_permit, :boolean, comment: '勤怠変更送信許可のチェック'
  end
end
