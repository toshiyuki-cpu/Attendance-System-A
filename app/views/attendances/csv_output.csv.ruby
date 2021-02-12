require 'csv'

CSV.generate do |csv|
  column_names = %w(日付 曜日 出社時間 退社時間)
  csv << column_names
  @attendances.each do |attendance|
    column_values = [
      l(attendance.worked_on, format: :short),
      $days_of_the_week[attendance.worked_on.wday],
      attendance.started_at&.strftime("%R"),
      attendance.finished_at&.strftime("%R")
    ]
    csv << column_values
  end
end