class BasesController < ApplicationController
  before_action :logged_in_user, only: [:index, :new, :creat, :edit, :destroy]
  before_action :admin_or_correct_user, only: [:index, :new, :creat, :edit, :update, :destroy]
  before_action :admin_user, only: [:index, :new, :creat, :edit, :update, :destroy]
  
  def index
    @bases = Base.all
  end

  def new
    @base = Base.new
  end

  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = "拠点の#{@base.base_name}を追加しました。" #:successというキーには保存に成功した時のメッセージを代入
      redirect_to bases_url(@base) # 左記のように記述できる　redirect_to user_url(@user)
    else
      render :new
    end
  end

  def edit
    @base = Base.find(params[:id])
  end

  def update
    @base = Base.find(params[:id])
    if @base.update_attributes(base_params)
      flash[:success] = '拠点情報を修正しました。'
      redirect_to bases_url
    else
      render :edit
    end
  end

  def destroy
    @base = Base.find(params[:id]) # set_userへ
    @base.destroy
    flash[:success] = "#{@base.base_name}のデータを削除しました。"
    redirect_to bases_url
  end
  
end

  private

# このメソッドはparams[:base]の代わり
def base_params
  params.require(:base).permit(:base_number, :base_name, :base_type) # Storong Parameter
  # 必須となるパラメータと許可されたパラメータを指定することができる
  # paramsハッシュでは:userキーを必須とする
end

def logged_in_user
  unless logged_in?
    store_location
    flash[:danger] = "ログインしてください。"
    redirect_to login_url
  end
end

# システム管理権限所有かどうか判定します。
def admin_user
  redirect_to root_url unless current_user.admin?
end

def admin_or_correct_user
  unless current_user.admin?
  flash[:danger] = '編集権限がありません。'
  redirect_to(root_url)
  end
end

