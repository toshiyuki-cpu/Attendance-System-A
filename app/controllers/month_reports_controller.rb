class MonthReportsController < ApplicationController
    
    def report_apply
      @user = User.find(params[:user_id])
      @month_report = MonthReport.find(params[:month_report_id])
      @superiors = User.superior_except_me(current_user)
    end
    
    def update_report_apply
      @user = User.find(params[:user_id])
      @month_report = MonthReport.find(params[:month_report_id])
    end
    
    private
    
    def report_apply_params
      params.require(:month_report).permit(:report_approver, :report_month, :report_status)
    end
end
