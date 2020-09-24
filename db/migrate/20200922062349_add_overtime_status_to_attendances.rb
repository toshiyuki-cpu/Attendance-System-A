class AddOvertimeStatusToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overtime_status, :string, comment: '残業申請状態(申請中、承認、否認、なし)'
  end
end
