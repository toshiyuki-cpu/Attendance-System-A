#Rubyでは「sessionを実装する為にたくさんのメソッド」にあたるメソッドを一箇所にパッケージ化して使いまわすことが出来るモジュール機能がある。
#sessions_helper.rb（ヘルパー）を使えば、メソッドのパッケージ化ができます
module SessionsHelper #アプリケーションコントローラーにヘルパーを読み込ませる
  
  def log_in(user) #log_inヘルパーメソッドを定義したことにより、ユーザーのログインを行ってcreateアクションを完了してユーザー情報ページへリダイレクトする準備が整う
    session[:user_id] = user.id #このコードを実行すると、ユーザーのブラウザ内にある一時的cookiesに暗号化済みのuser.idが自動で生成される
  end
  
  def current_user #現在ログインしているユーザー
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id]) # ||(or演算子)
    end
  end
end
