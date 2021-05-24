class SessionsController < ApplicationController
  
  def new
  end
  
  def create
    user = User.find_by(email: params[:session][:email].downcase) #ログインフォームから受け取ったemailの値を使ってユーザーオブジェクトを検索
    if user && user.authenticate(params[:session][:password]) # &&は取得したユーザーオブジェクトが有効か判定するために使用
      log_in user #引数として指定するためのカッコ()を省略して記述 log_in(user)
                  #log_inメソッドの機能で、ユーザーIDを一時的セッションの中に安全に記憶するようになった
                  
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      # チェックボックスの値を評価します。オンの時はユーザー情報を記憶します。オフの場合は記憶しません。
      # 三項演算子 [条件式] ? [真（true）の場合実行される処理] : [偽（false）の場合実行される処理]
      if current_user.admin?
        redirect_to users_url
      else
        redirect_back_or user_url(user, date: Time.current.beginning_of_month.to_date.to_s) #引数にuserを指定することで、デフォルトのURLを設定しています
      end
    else
      flash.now[:danger] = '認証に失敗しました。' # .nowはリダイレクトはしないがフラッシュを表示したい時
      render :new
    end
  end
  
  def destroy
    log_out if logged_in?
    flash[:success] = 'ログアウトしました。'
    redirect_to root_path
  end
end
