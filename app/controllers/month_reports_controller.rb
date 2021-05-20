class MonthReportsController < ApplicationController
  
  # @month_report = @user.month_reports.find_or_create_by(user_id: current_user, month: params[:date]) 
  def create
    # STEP 1:user_idを取得 
    @user = User.find(params[:user_id])
    # STEP 2:新規作成
    month_report = MonthReport.new(month_report_params)
    # STEP 3:statusに申請中を代入
    month_report.status = 'applying'
    # userのidを取得
    month_report.user = current_user
    # STEP 4:保存
    month_report.save
    flash[:success] = "#{month_report.month_report_apply_superior.name}に1ヶ月分の勤怠を申請しました。"
    redirect_to user_url(@user, date: @first_day)
    #redirect_back(fallback_location: user_url)
  end
  
  # 上長へ送信
  def update
    @user = User.find(params[:user_id])
    month_report = MonthReport.find(params[:id]) # flashメッセージに上長の名前を表示させる為定義
    month_report.attributes = month_report_params
    month_report.status = 'applying'
    month_report.save
    flash[:success] = "#{month_report.month_report_apply_superior.name}に1ヶ月分の勤怠を申請しました。"
    redirect_to user_url(@user, date: month_report.month)
    #redirect_back(fallback_location: user_url)
  end
  
  # モーダル表示で必要なくなった
  # 上長画面：社員からの1ヶ月分の勤怠表示・送信
  #def receiving
    #@user = User.find(params[:user_id])
    #@month_report = MonthReport.find(params[:month_report_id])
    # STEP1: パラメーターのmonth_report.statusを取得
    #@month_report.status = params[:month_report][:status]
    # STEP2: チェックボックスがtrueの時送信
    #if params[:report][:reply] 
      #@month_report.save
    #end
    #flash[:success] = '1ヶ月分の勤怠申請を申請者へ送信しました。'
    # 送信後、なぜかstring parameterにdateが渡ってないので、引数にdate: Time.current.beginning_of_month.to_date.to_sを入れた
    #redirect_to user_url(current_user, date: Time.current.beginning_of_month.to_date.to_s)
  #end
  
  def receiving_index
    @user = User.find(params[:user_id])
    @month_report = MonthReport.find(params[:month_report_id])
    @report_receivings = MonthReport.where(approver_id: @user.id, status: 'applying').group_by { |item| item.user }
  end
  
  def receiving_employee
    @user = User.find(params[:id])
    @report_receivings = MonthReport.where(approver_id: @user.id, status: 'applying').group_by { |item| item.user }
  end
  
  # 1ヶ月の勤怠申請返信
  def reply_employee
    @user = User.find(params[:id])
    month_reports_params.each do |id, item|
      if item[:reply] == "0"
      # month_report = MonthReport.find(id)
      # month_report.status = item[:status]
      # if item[:reply] == "0" 
        next
      end
      month_report = MonthReport.find(id)
      month_report.status = item[:status]
      month_report.save(item)
      flash[:success] = '1ヶ月分の勤怠申請を申請者へ送信しました。'
    end
    flash[:danger] = "変更にチェックを入れて下さい。" if flash[:success].blank?
    # 送信後、なぜかstring parameterにdateが渡ってないので、引数にdate: Time.current.beginning_of_month.to_date.to_sを入れた
    redirect_to user_url(current_user, date: Time.current.beginning_of_month.to_date.to_s)
  end
  
  def reply
    @user = User.find(params[:user_id])
    @month_report = MonthReport.find(params[:month_report_id])
    # STEP1: パラメーターのmonth_report.statusを取得
    @month_report.status = params[:month_report][:status]
    # STEP2: チェックボックスがtrueの時送信
    if params[:report][:reply] 
      @month_report.save
    end
    flash[:success] = '1ヶ月分の勤怠申請を送信しました。'
    # 送信後、なぜかstring parameterにdateが渡ってないので、引数にdate: Time.current.beginning_of_month.to_date.to_sを入れた
    redirect_to user_url(current_user, date: Time.current.beginning_of_month.to_date.to_s)
  end
  
  private
    
  def month_report_params
    params.require(:month_report).permit(:approver_id, :month)
  end
  
  def month_reports_params
    params.require(:user).permit(month_reports: [:status, :reply])[:month_reports]
  end
end
