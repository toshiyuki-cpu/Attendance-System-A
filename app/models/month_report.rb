# == Schema Information
#
# Table name: month_reports
#
#  id          :integer          not null, primary key
#  month       :date
#  status      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  approver_id :integer
#  user_id     :integer
#
class MonthReport < ApplicationRecord
  belongs_to :user
  # approver_idを外部キーのカラムと認識させるためuserのidとmonth_reportのapprover_idを外部キーとして関連付ける
  # month_reportヘルパーファイルでも定義している
  belongs_to :month_report_apply_superior, class_name: 'User', foreign_key: :approver_id, optional: true
  
  extend Enumerize
  # 1ヶ月の勤怠申請状態 ymlファイルも定義する 
  enumerize :status, in: %i(applying approval negation cancel), scope: true
end
