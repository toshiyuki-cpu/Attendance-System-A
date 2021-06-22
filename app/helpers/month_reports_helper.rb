module MonthReportsHelper
  def month_report_status_text(month_report)
    case month_report.status
    when 'applying'
      "#{month_report.month_report_apply_superior.name}に申請中"
    when 'approval'
      "#{month_report.month_report_apply_superior.name}から承認済🟠"
    when 'negation'
      "#{month_report.month_report_apply_superior.name}から否認"
    when 'cancel'
      "#{month_report.month_report_apply_superior.name}からキャンセル"
    end
  end
end
