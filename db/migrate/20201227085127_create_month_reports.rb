class CreateMonthReports < ActiveRecord::Migration[5.1]
  def change
    create_table :month_reports do |t|
      t.date :month, comment: 'どの月の1ヶ月の勤怠申請か'
      t.string :status, comment: '1ヶ月の勤怠申請のステータス'
      t.integer :approver_id, comment: '1ヶ月の勤怠申請の承認者'
      t.integer :user_id

      t.timestamps
    end
  end
end
