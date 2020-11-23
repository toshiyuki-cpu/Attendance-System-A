class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month, :edit_overtime_work_end_plan, :update_overtime_work_end_plan]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: [:edit_one_month, :edit_overtime_work_end_plan, :update_overtime_work_end_plan]
    
  # 定数は下記のように大文字表記
  # 更新エラー用のテキストを2ヶ所で使用しているため、このように定義
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0)) #　changeメソッド　秒数を０に変換する
        # update_attributes バリデーションを通す
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
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
  
  def edit_one_month # ルーティングattendances/edit_one_monthを設定してからアクションを定義
  end
  
  def update_one_month # ルーティングattendances/update_one_monthを設定してからアクションを定義
    ActiveRecord::Base.transaction do # トランザクションを開始します。
    attendances_params.each do |id, item|
    # id,itemはattendances_params（Attendanceモデルオブジェクト）の中の
    # {"1" => {"started_at"=>"10:00", "finished_at"=>"18:00", "note"=>"シフトA"},
      attendance = Attendance.find(id)
      attendance.update_attributes!(item)
    # 今回のように!をつけている場合はfalseでは無く例外処理を返します
    # 繰り返し処理で複数のオブジェクトのデータを更新する場合は、これらの処理が全て正常に終了することを保証することが大事です。
    # あるデータは更新できたが、あるデータは更新できていなかった。となるとデータの整合性がなくなってしまいます
      end
    end
    flash[:success] = "１ヶ月分の勤怠��報を更新しました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  
  def change_attendance_reply # 勤怠変更申請
  
    # STEP1 userのattendanceオブジェクトを取得
    @user = User.find(params[:id])
    @attendance = Attendance.find(params[:id])

    # change_attendance_statusにapplyingを代入
    #@attendance.change_attendance_status = :applying
    
    @attendance.update_attributes(change_attendance_params)
    
    flash[:success] = "変更を送信しました。"
    
    redirect_to user_url(date: params[:date])
    
      
  end
  
  def edit_log
  end
  
  def edit_overtime_work_end_plan
    # set_user定義
    # set_one_month定義
  end
  
  def update_overtime_work_end_plan
    # @user = User.find(params[:user_id])
    # @attendance = Attendance.find(params[:id])
    overtime_work_end_plan_params.each do |id, item|
    # id,itemはattendances_params（Attendanceモデルオブジェクト）の中
      attendance = Attendance.find(id)
      attendance.overtime_status = :applying # 指示者確認欄にapplyingと表示
      attendance.change_permit = 0 # 再申請すると上長ページでチェックが入ってしまうのでfalseで返す。
      attendance.update_attributes(item)
    end
      flash[:success] = "残業を申請しました。"
      
    # params idでattendanceオブジェクトを取得
      attendance = Attendance.find(params[:user][:attendances].keys.first)
      
    # worked_onの日付から月の初日をとる
      first_day = attendance.worked_on.beginning_of_month
     
    # ストリングパラメータの値に月初を入れてリダイレクトする
      redirect_to user_url(date: first_day)
      
    # redirect_back(fallback_location: user_url) この１行でも実装可能（74から81行省略して）
  end
  
  # 残業申請承認、社員へ返信
  def overtime_approval_reply
    # STEP1
    # 対象のattendanceオブジェクトを探す(paramsのなかに対象のattendanceのidがはいっているはず)
    @attendance = Attendance.find(params[:attendance_id])
   
    # STEP2
    # @attendanceのovertime_statusを変更する
    # paramsの中にviewから渡ってきたovertime_statusがあります。その値を@attendanceのovertime_statusに代入してあげます。
    @attendance.overtime_status = params[:attendance][:overtime_status]
    
    # STEP3
    # チェックボックスがtrueの時、@attendanceにtrue代入。そして@attendanceを保存します。
    # チェックボックス がfalseなら更新できない。viewに required: true追加してメッセージ出す
    # (check_boxヘルパーのチェックボックス に入力された値をコントローラーやモデルで使用する時は
    # params[モデル名][カラム名]で取得する（値が格納される)) 注意）htmlで記述されたname属性の中身に依る
    if @attendance.change_permit = params[:attendance][:change_permit]
       @attendance.save
    end
      
    # STEP4
    # 上長（現在ログインしている上長）の勤怠ページにリダイレクト（今回はリロード）します。
    flash[:success] = '変更を申請者へ送信しました。'
    redirect_to user_url(current_user)
  end
  
  private
  
  # 勤怠変更申請パラメーター
  def change_attendance_params
    params.require(:attendance).permit(:started_at, :finished_at, :next_day, :note, :change_superior_id, :change_attendance_status)
    
  end
  
  # 1ヶ月分の勤怠情報を扱います。
  def attendances_params
    params.require(:user).permit(attendances: [:started_at, :finished_at, :next_day, :note, :change_superior_id, :change_attendance_status])[:attendances]
  end
  
    # 残業申請のパラメーター
  def overtime_work_end_plan_params
    params.require(:user).permit(attendances: [:overtime_work_end_plan, :next_day, :overtime_content, :select_superior_id, :overtime_status, :change_permit])[:attendances]
  end
    # paramsハッシュの中の、
    # :userがキーのハッシュの中の、
    # :attendancesがキーのハッシュの中の
    # idがキーで、各カラム名がキーとなり、値がバリューとなった
    # この説明ですが、これらを上記のコードと合わせていくと・・・
    # paramsハッシュの中の・・・params
    # :userがキーのハッシュの中の・・・require(:user)
    # :attendancesがキーのハッシュの中にネストされたidと各カラムの値があるハッシュ
    # ・・・permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    # このメソッドでパラメータを取得すると次のようになります
    # {"1" => {"started_at"=>"10:00", "finished_at"=>"18:00", "note"=>"シフトA"},
    # {"2"=> {"started_at"=>"11:00", "finished_at"=>"19:00", "note"=>"シフトB"},
    # {"3"=> {"started_at"=>"12:00", "finished_at"=>"20:00", "note"=>"シフトC"}
    
    # beforeフィルター
    # 管理権限者、または現在ログインしているユーザーを許可します。
  def admin_or_correct_user
    # どちらかの条件式がtrueか、どちらもtrueの時には何も実行されない処理。
    # このフィルターに引っかかった場合は、トップページへ強制移動
    @user = User.find(params[:user_id]) if @user.blank?
    unless current_user?(@user) || current_user.admin?
      flash[:danger] = "編集権限がありません。"
      redirect_to(root_url)
    end  
  end
end
