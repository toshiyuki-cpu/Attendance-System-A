class BasesController < ApplicationController
  
  def index
    @bases = Base.all
    #@base = Base.new
  end
  
  def new
    @base = Base.new
  end
  
  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = "拠点の#{@base.base_name}を追加しました。" #:successというキーには保存に成功した時のメッセージを代入
      redirect_to bases_url(@base) #左記のように記述できる　redirect_to user_url(@user)
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
      flash[:success] = "拠点情報を修正しました。"
      redirect_to bases_url
    else
      render :edit
    end
  end
  
  def destroy
    @base = Base.find(params[:id]) #set_userへ
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

