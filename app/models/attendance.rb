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
  belongs_to :superior, class_name: 'User', foreign_key: :select_superior_id, optional: true 
  
  extend Enumerize
  # 残業申請状態　ymlファイルも定義する　
  enumerize :overtime_status, in: %i(applying approval negation cancel), scope: true
  
  # 勤怠変更申請状態　ymlファイルも定義する
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
  validate :finished_at_is_invalid_without_a_started_at
  # 存在性の検証などではvalidatesのようにsが入りましたが、今回のパターンだと不要
  # この記述によりfinished_at_is_invalid_without_a_started_atを検証の際に呼び出します
  
  # 出勤・退勤時間どちらも存在する時、出勤時間より早い退勤時間は無効
  validate :started_at_than_finished_at_fast_if_invalid
  
  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
                                             #「出勤時間が無い、かつ退勤時間が存在する場合」、trueとなって処理が実行される
  end
  
  def started_at_than_finished_at_fast_if_invalid
    # validateクラスメソッドを使って新しく定義したカスタムメソッドを呼び出します。
    # しかし、今回に限っては設定したエラーメッセージをアプリケーション上で表示することはありません。
    # 今回は例外処理を発生させるためにこのようなカスタムメソッドを作成
    if started_at.present? && finished_at.present?
      errors.add(:started_at, "より早い退勤時間は無効です") if started_at > finished_at
    end
  end
  
  # change_attendance_approval_replyアクションで使用。変更後カラムを変更前カラムに代入後カラムの値をnilにする
  def reset_change_attendance_columns
    self.change_started_at = nil
    self.change_finished_at = nil
    self.change_note = nil
  end
end
