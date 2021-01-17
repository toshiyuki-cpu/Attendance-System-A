# == Schema Information
#
# Table name: attendances
#
#  id                            :integer          not null, primary key
#  change_attendance_permit      :boolean
#  change_attendance_status      :string
#  change_finished_at            :datetime
#  change_note                   :string
#  change_permit                 :boolean
#  change_started_at             :datetime
#  finished_at                   :datetime
#  hours_of_overtime             :string
#  next_day                      :boolean
#  note                          :string
#  overtime_content              :string
#  overtime_status               :string
#  overtime_work_end_plan        :datetime
#  started_at                    :datetime
#  worked_on                     :date
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  change_attendance_superior_id :integer
#  select_superior_id            :integer
#  user_id                       :integer
#
# Indexes
#
#  index_attendances_on_user_id  (user_id)
#
class Attendance < ApplicationRecord # AttendanceモデルからみたUserモデルとの関連性は1対1
  belongs_to :user
  # rails g model Attendance worked_on:date started_at:datetime finished_at:datetime note:string user:referencesにより
  # Attendanceモデルが生成され、コードでは、Userモデルと1対1の関係を示すbelongs_to :userというコードが記述されています。
  # これは先ほど実行したコマンドにuser:referenceという引数を含めたためです。
  # この引数を使うと、自動的にuser_id属性が追加されActiveRecordがUserモデルとAttendanceモデルを紐付ける準備をしてくれます

  # select_superior_idを外部キーのカラムと認識させるためuserのidとattendanceのselect_superior_idを外部キーとして関連付ける
  # optional: trueとは、アソシエーションによって紐づけられた外部キーの値が存在していなくても、データベースに保存することができるオプション
  belongs_to :overtime_reply_superior, class_name: 'User', foreign_key: :select_superior_id, optional: true
  
  belongs_to :change_attendance_reply_superior, class_name: 'User', foreign_key: :change_attendance_superior_id, optional: true
  
  extend Enumerize
  # 残業申請状態 ymlファイルも定義する 
  enumerize :overtime_status, in: %i(applying approval negation cancel), scope: true
  
  # 勤怠変更申請状態 ymlファイルも定義する
  enumerize :change_attendance_status, in: %i(applying approval negation cancel), scope: true
  
  validates :worked_on, presence: true
  # worked_onはどの日付の勤怠情報かを判断する上で必須,存在性の検証が必要なのはworked_on
  # user_idは今回の追加方法ですとデフォルトで存在性の検証を行ってくれる
  validates :note, length: { maximum: 50 }
  
  validates :change_note, length: { maximum: 50 }
  
  validates :overtime_content, length: { maximum: 50 } #業務処理内容（残業申請）
  
  # 出勤時間が存在しない場合、退勤時間は無効
  # Railsではモデルの状態を確認し、無効な場合errorsオブジェクトにメッセージを追加するメソッドを作成することができます。
  # このメソッドを作成後、バリデーションメソッド名を指すシンボルを渡しvalidateクラスメソッドを使って登録する必要があります
  # 存在性の検証などではvalidatesのようにsが入りましたが、今回のパターンだと不要
 
  validate :change_finished_at_is_invalid_without_a_change_started_at
  
  validate :change_strted_at_is_invalid_without_a_change_finished_at
  
  validate :change_started_at_than_change_finished_at_fast_if_invalid
  
  validate :change_note_or_change_attendance_superior_id_if_invalid
  
  validate :next_day_only_invalid
  
  validate :next_day_and_change_note_only_invalid
  
  validate :change_note_and_change_attendance_superior_id_if_invalid
  
  validate :superior_if_invalid, on: :change_attendance_update
  
  # validateクラスメソッドを使って新しく定義したカスタムメソッドを呼び出します。
  # 今回は例外処理を発生させるためにこのようなカスタムメソッドを作成
  # validate :change_finished_at_is_invalid_without_a_change_started_at
  #「出勤時間が無い、かつ退勤時間が存在する場合」、trueとなって処理が実行される
  def change_finished_at_is_invalid_without_a_change_started_at
    errors.add(:change_started_at, "が必要です") if change_started_at.blank? && change_finished_at.present?
  end
  # validate :change_strted_at_is_invalid_without_a_change_finished_at
  #「退勤時間が無い、かつ出勤時間が存在する場合」
  def change_strted_at_is_invalid_without_a_change_finished_at
    errors.add(:change_finished_at, "が必要です") if change_finished_at.blank? && change_started_at.present?
  end
  # validate :change_started_at_than_change_finished_at_fast_if_invalid
  # 出勤時間、退勤時間、翌日カラムが存在して「退勤時間が出勤時間より早い場合」
  def change_started_at_than_change_finished_at_fast_if_invalid
    if change_started_at.present? && change_finished_at.present? && next_day.blank?
      errors.add(:change_started_at, "より早い退勤時��は無効です") if change_started_at > change_finished_at
    end
  end
  # validate :change_note_or_change_attendance_superior_id_if_invalid
  # 出勤時間が無い、かつ退勤時間が無い、かつ翌日カラムがなくて「備考又は上長idが存在する時」
  def change_note_or_change_attendance_superior_id_if_invalid
    if change_started_at.blank? && change_finished_at.blank? && next_day.blank?
      errors.add(:change_note, "が必要です") if change_note.present? || change_attendance_superior_id.present?
    end  
  end
  # validate :next_day_only_invalid
  #「出勤時間が無い、かつ退勤時間が無い、かつ備考が無い時「翌日カラムが存在する」場合
  def next_day_only_invalid
    if change_started_at.blank? && change_finished_at.blank? && change_note.blank?
      errors.add(:change_started_at, "が必要です") if next_day.present? 
    end
  end
  # validate :next_day_and_change_note_only_invalid
  # 出勤時間が無い、かつ退勤時間が無い、かつ上長idが存在して「翌日カラム、かつ備考が存在する時」
  def next_day_and_change_note_only_invalid
    if change_started_at.blank? && change_finished_at.blank? && change_attendance_superior_id.present?
      errors.add(:change_started_at, :change_finished_at, "が必要です") if next_day.present? && change_note.present? 
    end
  end
  # validate :change_note_and_change_attendance_superior_id_if_invalid
  # 出勤時間、かつ退勤時間が存在して、「備考かつ上長idが存在しない時」
  def change_note_and_change_attendance_superior_id_if_invalid
    if change_started_at.present? && change_finished_at.present?
      errors.add(:change_note, "が必要です") if change_note.blank? && change_attendance_superior_id.blank?
    end
  end
  # validate :superior_if_invalid, on: :change_attendance_update
  # 上長選択しなかったら
  def superior_if_invalid
    if change_attendance_superior_id.blank?
      errors.add(:change_attendance_superior_id, "を選択して下さい。")
    end
  end
  
  # change_attendance_approval_replyアクションで使用。変更後カラムを変更前カラムに代入後カラムの値をnilにする
  #def reset_change_attendance_columns
    #self.change_started_at = nil
    #self.change_finished_at = nil
    #self.change_note = nil
  #end
end
