class BasesController < ApplicationController
  
  def index
    @bases = Base.all
    @base = Base.new
  end
  
  def show
  end
  
  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = '#{@base.base_name}の拠点情報を追加しました。' #:successというキーには保存に成功した時のメッセージを代入
      redirect_to bases_url #左記のように記述できる　redirect_to user_url(@user)
    else
      render :new
    end
  end
  
  def destroy
    #@user = User.find(params[:id]) set_userへ
    @base.destroy
    flash[:success] = "#{@base.base_name}のデータを削除しました。"
    redirect_to bases_url
  end
end

private

def base_params #このメソッドはparams[:base]の代わり
    params.require(:base).permit(:base_number, :base_name, :base_type) #Storong Parameter
    #必須となるパラメータと許可されたパラメータを指定することができる
    #paramsハッシュでは:userキーを必須とする
end

