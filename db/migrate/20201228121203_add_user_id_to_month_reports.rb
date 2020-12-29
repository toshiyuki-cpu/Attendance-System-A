class AddUserIdToMonthReports < ActiveRecord::Migration[5.1]
  def change
    add_column :month_reports, :user_id, :integer
  end
end
