class AddChangePermitToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change_permit, :boolean, comment: '残業申請の変更許可'
  end
end
