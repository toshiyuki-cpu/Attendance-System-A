class AttendancesController < ApplicationController
  before_action :set_user, only: :edit_one_month
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :set_one_month, only: :edit_one_month
  
  #定数は下記のように大文字表記
  #更新エラー用のテキストを2ヶ所で使用しているため、このように定義
  UPDATE＿ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0)) #　changeメソッド　秒数を０に変換する
        # update_attributes バリデーションを通す
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE＿ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
          flash[:info] = "お疲れ様でした。"
      else
          flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end
  
  def edit_one_month #ルーティングattendances/edit_one_monthを設定してからアクションを定義
  end
  
  def update_one_month #ルーティングattendances/update_one_monthを設定してからアクションを定義
    ActiveRecord::Base.transaction do # トランザクションを開始します。
    attendances_params.each do |id, item|
      #id,itemはattendances_params（Attendanceモデルオブジェクト）の中の
      #{"1" => {"started_at"=>"10:00", "finished_at"=>"18:00", "note"=>"シフトA"},
      attendance = Attendance.find(id)
      attendance.update_attributes!(item)
      #今回のように!をつけている場合はfalseでは無く例外処理を返します
      #繰り返し処理で複数のオブジェクトのデータを更新する場合は、これらの処理が全て正常に終了することを保証することが大事です。
      #あるデータは更新できたが、あるデータは更新できていなかった。となるとデータの整合性がなくなってしまいます
      end
    end
    flash[:success] = "１ヶ月分の勤怠情報を更新しました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  
  private
  
  # 1ヶ月分の勤怠情報を扱います。
  def attendances_params
    params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
  end
  #paramsハッシュの中の、
  #:userがキーのハッシュの中の、
  #:attendancesがキーのハッシュの中の
  #idがキーで、各カラム名がキーとなり、値がバリューとなった
  #この説明ですが、これらを上記のコードと合わせていくと・・・
  #paramsハッシュの中の・・・params
  #:userがキーのハッシュの中の・・・require(:user)
  #:attendancesがキーのハッシュの中にネストされたidと各カラムの値があるハッシュ
  #・・・permit(attendances: [:started_at, :finished_at, :note])[:attendances]
  #このメソッドでパラメータを取得すると次のようになります
  #{"1" => {"started_at"=>"10:00", "finished_at"=>"18:00", "note"=>"シフトA"},
  #{"2"=> {"started_at"=>"11:00", "finished_at"=>"19:00", "note"=>"シフトB"},
  #{"3"=> {"started_at"=>"12:00", "finished_at"=>"20:00", "note"=>"シフトC"}
end
