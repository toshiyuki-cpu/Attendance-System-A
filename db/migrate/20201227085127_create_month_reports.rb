class CreateMonthReports < ActiveRecord::Migration[5.1]
  def change
    create_table :month_reports do |t|
      t.date :report_month, comment: 'どの月の1ヶ月の勤怠申請か'
      t.string :report_status, comment: '1ヶ月の勤怠申請のステータス'
      t.string :report_approver, comment: '1ヶ月の勤怠申請の承認者'
      

      t.timestamps
    end
  end
end
