class ChangeDatatypeReportApproverOfMonthReports < ActiveRecord::Migration[5.1]
  def change
    change_column :month_reports, :report_approver, :integer 
  end
end
