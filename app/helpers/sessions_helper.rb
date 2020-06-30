#Rubyでは「sessionを実装する為にたくさんのメソッド」にあたるメソッドを一箇所にパッケージ化して使いまわすことが出来るモジュール機能がある。
#sessions_helper.rb（ヘルパー）を使えば、メソッドのパッケージ化ができます
module SessionsHelper #アプリケーションコントローラーにヘルパーを読み込ませる

  # 引数に渡されたユーザーオブジェクトでログインします。
  def log_in(user) #log_inヘルパーメソッドを定義したことにより、ユーザーのログインを行ってcreateアクションを完了してユーザー情報ページへリダイレクトする準備が整う
    session[:user_id] = user.id #このコードを実行すると、ユーザーのブラウザ内にある一時的cookiesに暗号化済みのuser.idが自動で生成される
  end
  
  # セッションと@current_userを破棄します
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
  
  def current_user #現在ログインしているユーザー
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id]) # ||(or演算子)
    end
  end
  
  def logged_in? #ログイン状態を論理値（trueかfalse）で返すヘルパーメソッド（logged_in?）を定義
    !current_user.nil? #trueはログイン状態、falseはログアウト状態 否定演算子!
  end
end
