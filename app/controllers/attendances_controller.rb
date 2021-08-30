class AttendancesController < ApplicationController
  before_action :set_user, only: %i[editing_one_month updating_one_month approval_log]
  before_action :logged_in_user, only: %i[update editing_one_month]
  before_action :admin_or_correct_user, only: %i[update editing_one_month updating_one_month approval_log]
  before_action :set_one_month, only: [:editing_one_month]
  before_action :authorize_admin, only: %i[editing_one_month]

  # 定数は下記のように大文字表記
  # 更新エラー用のテキストを2ヶ所で使用しているため、このように定義
  UPDATE_ERROR_MSG = '勤怠登録に失敗しました。やり直してください。'

  # 勤怠のcsv出力
  # viewファイルも作成（csv_output.csv.ruby）
  def csv_output
    @user = User.find(params[:id])
    @first_day = params[:date].nil? ? Time.current.beginning_of_month : params[:date].to_date
    @last_day = @first_day.end_of_month
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    # ↑の定義、アプリケーションコントローラーのset_user , set_one_month
    respond_to do |format|
      format.csv do |_csv|
        send_data render_to_string, filename: "#{@user.name}の勤怠.csv", type: :csv
      end
    end
  end

  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0)) # changeメソッド 秒数を０に変換する
        # update_attributes バリデーションを通す
        flash[:info] = 'おはようございます！'
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = 'お疲れ様でした。'
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end

  # 勤怠変更申請、上長へまとめて送信の表示
  def editing_one_month
    @superiors = User.superior_except_me(current_user)
  end

  # 勤怠変更申請、上長へまとめて送信
  def updating_one_month
    @user = User.find(params[:id])
    @attendance = Attendance.find(params[:id])
    begin
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      change_attendances_params.each do |id, item| # idがkey,itemがvalue
        attendance = Attendance.find(id)
        # パラメーターを代入している
        attendance.attributes = item
        # 変更ないレコードはスルーさせる
        # { |v| v.blank? }　valueが空ならnext　
        # has_changes_to_save? 変更を検知して true / falseを返す
        # (!マークをつけている)attendanceが変更ない(false)ならnext
        next if item.values.all? { |v| v.blank? } || !attendance.has_changes_to_save?
        attendance.change_attendance_status = :applying
        attendance.save(context: :change_attendance_update) # コンテキストattendance.rbで
        # save!メソッド：保存に失敗したら例外が発生。保存できなかった場合の処理はrescue節で行う必要がある
        #rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
        @errors = attendance.errors.full_messages
        #@errors_count = attendance.errors.full_messages.count
        end
      end
    rescue
      #[:danger] = attendance.errors.full_messages.join(', ')
      #flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
      #flash[:danger] = attendance.errors.full_messages.to_sentence でも上と同じ
      #redirect_to attendances_editing_one_month_user_url(date: params[:date]) and return
    end
    if @errors.present?
      flash[:danger] = "無効な入力データがありました。再度申請して下さい。"
      redirect_to user_url(date: params[:date])
    else
      flash[:success] = "上長へ勤怠変更申請しました。"
      redirect_to user_url(date: params[:date])
    end
  end
  
  # 勤怠変更申請まとめて返信表示
  def receiving_one_month
    @user = User.find(params[:id])
    @attendances = Attendance.where(change_attendance_superior_id: @user.id,
                                    change_attendance_status: 'applying').group_by do |item|
      item.user
    end
  end

  # 勤怠変更申請まとめて返信
  def reply_one_month
    @user = User.find(params[:id])
    reply_one_month_params.each do |id, item|
      attendance = Attendance.find(id)
      attendance.attributes = item
      if attendance.change_attendance_permit == false
        next
      else
        if attendance.change_attendance_status.approval?
          # attendance.started_at = attendance.change_started_at
          # attendance.finished_at = attendance.change_finished_at
          attendance.note = attendance.change_note
          attendance.update_attributes(item)
        else
          attendance.change_attendance_status = item[:change_attendance_status]
          attendance.update_attributes(item)
        end
        flash[:success] = '勤怠変更を申請者へ送信しました。'
      end
    end
    # 1つでも承認があればflash[:danger]は表示させない
    flash[:danger] = '変更にチェックを入れて下さい。' if flash[:success].blank?
    redirect_to user_url(current_user)
  end

  # 勤怠ログ（勤怠変更申請の承認済）
  def approval_log
    @user = User.find(params[:id])
    # Parameters: {"utf8"=>"✓", "search(1i)"=>"2021", "search(2i)"=>"2", "search(3i)"=>"1", "commit"=>"検索", "id"=>"5"}をTimeWithZoneクラスに変換
    beginning_of_month = "#{params['search(1i)']}-#{params['search(2i)']}-#{params['search(3i)']}".in_time_zone
    # @beginning_of_monthがなければ@end_of_monthはエラーになるためif文追加
    end_of_month = beginning_of_month.end_of_month if beginning_of_month.present?
    @approval_logs = @user.attendances.where(worked_on: beginning_of_month..end_of_month,
                                             change_attendance_status: 'approval')
    # 変更前出社時間は出社時間（出社ボタン押した時間）を表示、もしnilなら一番最初に申請した変更前時刻
    # 変更前退社時間は退社時間（退社ボタン押した時間）を表示、もしnilなら一番最初に申請した変更前時刻
    # 変更後出社時間は一番最後に申請した変更後時刻を表示
    # 変更後退社時間は一番最後に申請した変更後時刻を表示
  end

  # 残業申請モーダル表示
  def edit_overtime_work_end_plan
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:attendance_id])
    # 選択フォームに自分を載せない
    # user.rbでscopeメソッド :superior_except_me, ->(user) { where.not(id: user).with_role(:superior) }
    @superiors = User.superior_except_me(current_user)
  end

  # 残業申請、上長へ送信
  def update_overtime_work_end_plan
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:attendance_id])
    @attendance.overtime_status = :applying # 指示者確認欄にapplyingと表示
    @attendance.change_permit = false # 再申請すると上長ページでチェックが入ってしまうのでfalseで返す。
    @attendance.update_attributes(overtime_work_end_plan_params)
    # end
    flash[:success] = '残業を申請しました。'
    # worked_onの日付から月の初日をとる
    first_day = @attendance.worked_on.beginning_of_month
    # ストリングパラメータの値に月初を入れてリダイレクトする
    redirect_to user_url(@user, date: first_day)
    # redirect_back(fallback_location: user_url) この１行でも実装可能（74から81行省略して）
  end

  # 社員からの残業申請表示（まとめて返信用ルーティング）
  def overtime_index
    @user = User.find(params[:id])
    @attendances = Attendance.where(select_superior_id: @user.id, overtime_status: 'applying').group_by do |item|
      item.user
    end
  end

  # 社員からの残業申請一括返信（まとめて返信用ルーティング）
  def overtime_reply
    @user = User.find(params[:id])
    overtime_reply_params.each do |id, item|
      attendance = Attendance.find(id)
      attendance.change_permit = false # 複数回同じ申請をチェックして繰り返すと、見た目チェック無しでもDB的にtrueになってしまうのでリセットする
      attendance.attributes = item
      # if attendance.change_permit == false
      next unless attendance.change_permit
      attendance.overtime_status = item[:overtime_status]
      attendance.update_attributes(item)
      flash[:success] = '社員からの残業申請を返信しました。'
    end
    flash[:danger] = '変更にチェックを入れて下さい。' if flash[:success].blank?
    redirect_to user_url(date: params[:date])
  end

  private

  # 勤怠変更前のパラメーター
  def attendance_params
    params.require(:attendance).permit(:started_at, :finished_at, :next_day, :note, :change_attendance_superior_id,
                                       :change_attendance_permit)
  end

  # 勤怠変更申請時のパラメーター
  def change_attendance_params
    params.require(:attendance).permit(:change_started_at, :change_finished_at, :next_day, :change_note,
                                       :change_attendance_superior_id, :change_attendance_status, :change_attendance_permit)
  end

  # 勤怠変更申請まとめて送信のパラメーター(アクション updating_one_month)
  def change_attendances_params
    params.require(:user).permit(attendances: %i[change_started_at change_finished_at next_day change_note
                                                 change_attendance_superior_id change_attendance_status change_attendance_permit])[:attendances]
  end

  # 勤怠変更申請まとめて返信のパラメーター（アクション reply_one_month)
  def reply_one_month_params
    params.require(:user).permit(attendances: %i[started_at change_started_at finished_at change_finished_at
                                                 next_day note change_note change_attendance_superior_id change_attendance_status change_attendance_permit])[:attendances]
  end

  # 1ヶ月分の勤怠情報を扱います。
  def attendances_params
    params.require(:user).permit(attendances: %i[started_at finished_at note next_day change_note
                                                 change_attendance_superior_id change_attendance_status change_attendance_permit])[:attendances]
  end

  # 残業申請のパラメーター
  def overtime_work_end_plan_params
    params.require(:attendance).permit(:overtime_work_end_plan, :next_day, :overtime_content, :select_superior_id,
                                       :overtime_status, :change_permit)
    # params.require(:user).permit(attendances: [:overtime_work_end_plan, :next_day, :overtime_content, :select_superior_id, :overtime_status, :change_permit])[:attendances]
  end

  # 残業申請まとめて返信のパラメーター
  def overtime_reply_params
    params.require(:user).permit(attendances: %i[overtime_work_end_plan next_day overtime_content
                                                 select_superior_id overtime_status change_permit])[:attendances]
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
      flash[:danger] = '編集権限がありません。'
      redirect_to(root_url)
    end
  end
  
  # 管理者の制限(勤怠編集画面に遷移させない）
  def authorize_admin
    if current_user.admin?
      flash[:danger] = '編集権限がありません。'
      redirect_to(root_url)
    end
  end
end
