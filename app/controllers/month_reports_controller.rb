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
    redirect_to user_url(current_user)
  end
  
  def update
    @user = User.find(params[:user_id])
    month_report = MonthReport.find(params[:id]) # flashメッセージに上長の名前を表示させる為定義
    month_report.attributes = month_report_params
    month_report.status = 'applying'
    month_report.save
    flash[:success] = "#{month_report.month_report_apply_superior.name}に1ヶ月分の勤怠を申請しました。"
    redirect_to user_url(current_user)
  end
  
  private
    
  def month_report_params
    params.require(:month_report).permit(:approver_id, :month)
  end
  
end
