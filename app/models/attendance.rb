class Attendance < ApplicationRecord #AttendanceモデルからみたUserモデルとの関連性は1対1
  belongs_to :user
  #　rails g model Attendance worked_on:date started_at:datetime finished_at:datetime note:string user:referencesにより
#Attendanceモデルが生成され、コードでは、Userモデルと1対1の関係を示すbelongs_to :userというコードが記述されています。
#これは先ほど実行したコマンドにuser:referenceという引数を含めたためです。
#この引数を使うと、自動的にuser_id属性が追加されActiveRecordがUserモデルとAttendanceモデルを紐付ける準備をしてくれます
  
  validates :worked_on, presence: true
  #worked_onはどの日付の勤怠情報かを判断する上で必須,存在性の検証が必要なのはworked_on
  # user_idは今回の追加方法ですとデフォルトで存在性の検証を行ってくれる
  validates :note, length: { maximum: 50 }
  
  # 出勤時間が存在しない場合、退勤時間は無効
  #Railsではモデルの状態を確認し、無効な場合errorsオブジェクトにメッセージを追加するメソッドを作成することができます。
  #このメソッドを作成後、バリデーションメソッド名を指すシンボルを渡しvalidateクラスメソッドを使って登録する必要があります
  validate :finished_at_is_invalid_without_a_started_at
  #存在性の検証などではvalidatesのようにsが入りましたが、今回のパターンだと不要
  #この記述によりfinished_at_is_invalid_without_a_started_atを検証の際に呼び出します
  
  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
                                             #「出勤時間が無い、かつ退勤時間が存在する場合」、trueとなって処理が実行される
  end
end
