class MonthReportsController < ApplicationController
    
  def new
    # STEP 1:user_idを取得
    @user = User.find(params[:user_id])
    @month_report = MonthReport.new
  end
  
  def create
    # STEP 1:user_idを取得 
    @user = User.find(params[:user_id])
    # STEP 2:month_reportのidを取得
    
    # STEP 3:month_report_idがDBに保存されてなければ新規で申請
    #@month_report = MonthReport.find_or_initialize_by(id: params[:id])
    #unless @month_report.new_record?
    #end
    # STEP 3:month_reportを新規作成し保存(申請)
    #@month_report.save
  end
    
    private
    
    def month_report_params
      params.require(:month_report).permit(:approver_id, :month, :status)
    end
end
