class AddChangeStartedAtToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change_started_at, :datetime, comment: '変更後の出勤時間'
  end
end
