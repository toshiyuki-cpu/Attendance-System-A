class SessionsController < ApplicationController
  
  def new
  end
  
  def create
    user = User.find_by(email: params[:session][:email].downcase) #ログインフォームから受け取ったemailの値を使ってユーザーオブジェクトを検索
    if user && user.authenticate(params[:session][:password]) # &&は取得したユーザーオブジェクトが有効か判定するために使用
      log_in user #引数として指定するためのカッコ()を省略して記述 log_in(user)
                  #log_inメソッドの機能で、ユーザーIDを一時的セッションの中に安全に記憶するようになった
      redirect_to user
    else
      flash.now[:danger] = '認証に失敗しました。' # .nowはリダイレクトはしないがフラッシュを表示したい時
      render :new
    end
  end
  
  def destroy
    log_out
    flash[:success] = 'ログアウトしました。'
    redirect_to root_path
  end
end
