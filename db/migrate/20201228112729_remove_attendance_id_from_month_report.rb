class RemoveAttendanceIdFromMonthReport < ActiveRecord::Migration[5.1]
  def change
    remove_reference :month_reports, :attendance, foreign_key: true
  end
end
