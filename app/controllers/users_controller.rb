class UsersController < ApplicationController
  
  def show
    @user = User.find(params[:id])
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params) #(params[:user]) userコントローラーにシンボルparams[:user]として渡している
    if @user.save
      flash[:success] = '新規作成に成功しました。' #:successというキーには保存に成功した時のメッセージを代入
      redirect_to @user #左記のように記述できる　redirect_to user_url(@user)
    else
      render :new
    end
  end
  
  private #Web経由で外部のユーザーが知る必要は無いため、次に記すようにRubyのprivateキーワードを用いて外部からは使用できないようにする
  
  def user_params #このメソッドは前述したparams[:user]の代わり
    params.require(:user).permit(:name, :email, :password, :password_confirmation) #Storong Parameter
    #必須となるパラメータと許可されたパラメータを指定することができる
    #paramsハッシュでは:userキーを必須とする
  end
end
