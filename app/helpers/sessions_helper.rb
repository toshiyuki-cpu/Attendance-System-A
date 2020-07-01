#Rubyでは「sessionを実装する為にたくさんのメソッド」にあたるメソッドを一箇所にパッケージ化して使いまわすことが出来るモジュール機能がある。
#sessions_helper.rb（ヘルパー）を使えば、メソッドのパッケージ化ができます
module SessionsHelper #アプリケーションコントローラーにヘルパーを読み込ませる

  # 引数に渡されたユーザーオブジェクトでログインします。
  def log_in(user) #log_inヘルパーメソッドを定義したことにより、ユーザーのログインを行ってcreateアクションを完了してユーザー情報ページへリダイレクトする準備が整う
    session[:user_id] = user.id #このコードを実行すると、ユーザーのブラウザ内にある一時的cookiesに暗号化済みのuser.idが自動で生成される
  end
  
  # 永続的セッションを記憶します（Userモデルを参照）
  def remember(user)
    user.remember
    # ユーザーIDと記憶トークンはペアで扱う必要があるので、cookieも永続化しなくてはなりません。
    # そこで、次のようにsignedとpermanentをメソッドチェーンで繋いで使います
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end
  
  # 永続的セッションを破棄します
  def forget(user)
    user.forget # Userモデル参照
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
  
  # セッションと@current_userを破棄します
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
  
  # 一時的セッションにいるユーザーを返します。
  # それ以外の場合はcookiesに対応するユーザーを返します。
  def current_user #現在ログインしているユーザー
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id) # ||(or演算子)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end
  
  # 渡されたユーザーがログイン済みのユーザーであればtrueを返します。
  def current_user?(user)
    user == current_user
  end
  
  def logged_in? #ログイン状態を論理値（trueかfalse）で返すヘルパーメソッド（logged_in?）を定義
    !current_user.nil? #trueはログイン状態、falseはログアウト状態 否定演算子!
  end
end
