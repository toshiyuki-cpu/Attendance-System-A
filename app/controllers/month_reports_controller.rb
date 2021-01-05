class MonthReportsController < ApplicationController
  
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
  
  def receiving
    @user = User.find(params[:user_id])
    @month_report = MonthReport.find(params[:month_report_id])
    # STEP1: パラメーターのmonth_report.statusを取得
    @month_report.status = params[:month_report][:status]
    
    # STEP2: チェックボックスがtrueの時送信
    if params[:report][:reply] == "1"
      
      @month_report.save
    end
    
    flash[:success] = '1ヶ月分の勤怠申請を申請者へ送信しました。'
    redirect_to user_url(current_user)
  end
  
  private
    
  def month_report_params
    params.require(:month_report).permit(:approver_id, :month)
  end
  
end
