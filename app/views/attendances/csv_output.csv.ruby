require 'csv'

CSV.generate do |csv|
  column_names = %w[日付 曜日 出社時間 退社時間]
  csv << column_names
  @attendances.each do |attendance|
    column_values = [
      l(attendance.worked_on, format: :short),
      $days_of_the_week[attendance.worked_on.wday],
      if attendance.change_started_at.present? && attendance.change_attendance_status.approval?
        attendance.change_started_at&.floor_to(15.minutes)&.strftime('%R')
      else
        attendance.started_at&.floor_to(15.minutes)&.strftime('%R')
      end,
      if attendance.change_finished_at.present? && attendance.change_attendance_status.approval?
        attendance.change_finished_at&.floor_to(15.minutes)&.strftime('%R')
      else
        attendance.finished_at&.floor_to(15.minutes)&.strftime('%R')
      end
    ]
    csv << column_values
  end
end
