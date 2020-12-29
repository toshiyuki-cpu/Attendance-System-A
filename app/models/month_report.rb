# == Schema Information
#
# Table name: month_reports
#
#  id              :integer          not null, primary key
#  report_approver :integer
#  report_month    :date
#  report_status   :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :integer
#
class MonthReport < ApplicationRecord
  belongs_to :user
  
  extend Enumerize
  # 1ヶ月の勤怠申請状態 ymlファイルも定義する 
  enumerize :report_status, in: %i(applying approval negation cancel), scope: true
end
