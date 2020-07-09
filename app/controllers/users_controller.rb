class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info] # ログイン済みのユーザー
  before_action :correct_user, only: [:edit, :update] # アクセスしたユーザーが現在ログインしているユーザーか
  before_action :admin_user, only: [:destroy, :edit_basic_info, :update_basic_info]
  
  def index
    # @users = User.all 
    #ページネーションを判定できるオブジェクトに置き換える
    @users = User.paginate(page: params[:page])
    #paginateではキーが:pageで値がページ番号のハッシュを引数にとります。
    #User.paginateは:pageパラメータに基づき、データベースからひとかたまりのデータを取得
  end
  
  def show
   # @user = User.find(params[:id]) set_userへ
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params) #(params[:user]) userコントローラーにシンボルparams[:user]として渡している
    if @user.save
      log_in @user # 保存成功後、ログインします。このメソッドによりリダイレクトされたページではログイン状態のレイアウトが表示される
      flash[:success] = '新規作成に成功しました。' #:successというキーには保存に成功した時のメッセージを代入
      redirect_to @user #左記のように記述できる　redirect_to user_url(@user)
    else
      render :new
    end
  end
  
  def edit
    # @user = User.find(params[:id]) set_userへ
  end
  
  def update
    #@user = User.find(params[:id]) set_userへ
    if @user.update_attributes(user_params) 
      # user controllerのvalidationにallow_nil: trueオプションを追加するとパスワード入力しなくても更新できる
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render :edit
    end
  end
  
  def destroy
    #@user = User.find(params[:id]) set_userへ
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def edit_basic_info
    #@user = User.find(params[:id]) set_userへ
  end
  
  def update_basic_info
    #@user = User.find(params[:id]) set_userへ
  end
  
  private #Web経由で外部のユーザーが知る必要は無いため、次に記すようにRubyのprivateキーワードを用いて外部からは使用できないようにする
  
  def user_params #このメソッドは前述したparams[:user]の代わり
    params.require(:user).permit(:name, :email, :department, :password, :password_confirmation) #Storong Parameter
    #必須となるパラメータと許可されたパラメータを指定することができる
    #paramsハッシュでは:userキーを必須とする
  end
  
  # beforeフィルター
  
  # paramsハッシュからユーザーを取得します。
  def set_user # show,edit,updateアクションの@user = User.find(params[:id])をset_userとして定義
    @user = User.find(params[:id])
  end
  
  #ログイン済みのユーザーか確認
  def logged_in_user
    unless logged_in? # unlessは条件式がfalseの場合のみ記述した処理が実行される構文
      store_location
      flash[:danger] = "ログインしてください。"
      redirect_to login_url
    end
  end
  
  # アクセスしたユーザーが現在ログインしているユーザーか確認
  def correct_user
    #@user = User.find(params[:id]) # アクセスしたユーザーを判定するため
    redirect_to(root_url) unless current_user?(@user) #current_user?(user) sessionsヘルパーで定義してある
  end
  
  # システム管理権限所有かどうか判定
  def admin_user
    redirect_to root_url unless current_user.admin?
  end
end
