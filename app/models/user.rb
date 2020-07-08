class User < ApplicationRecord #Userモデル
# 「remember_token」という仮想の属性を作成します。
  attr_accessor :remember_token
# before_saveとはActive Recordのコールバックメソッド
  before_save { self.email = email.downcase } #現在のメールアドレス（self.email）の値をdowncaseメソッドを使って小文字に変換
  
  validates :name, presence: true, length: { maximum: 50 } #presence 存在性
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i #正規表現を代入している（値が変化する事がない為定数として定義）
  
  validates :email, presence: true, length: { maximum: 100 },
                    format: { with: VALID_EMAIL_REGEX }, #formatオプション（有効なメアドだけにマッチする）
                    uniqueness: true #一意性（他に同じデータがない）
                    
  validates :department, length: { in: 2..30 }, allow_blank: true
  # inオプション「2文字以上かつ30文字以下」という検証を追加
  #allow_blank: true 値が空文字""の場合バリデーションをスルー
  
  validates :basic_time, presence: true
  
  validates :work_time, presence: true
  
  has_secure_password #パスワードをそのままの文字列ではなく、ハッシュ化した状態の文字列でデータベースに保存
                      # ハッシュ化とは、入力されたデータ（パスワード）を元に戻せないデータにする処理
                      
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
#has_secure_passwordを追加することで(bcryptと言うgemをインストール)
#1.ハッシュ化したパスワードを、データベースのpassword_digestというカラムに保存できるようになる。
#2.ペアとなる仮想的なカラムであるpasswordとpassword_confirmationが使えるようになる。さらに存在性と値が一致するかどうかの検証も追加される。
#3.authenticateメソッドが使用可能となる。
#このメソッドは引数の文字列がパスワードと一致した場合オブジェクトを返し、パスワードが一致しない場合はfalseを返す。
# allow_nil: trueはユーザー情報更新でパスワード入力しなくても更新できるメソッド

# 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = 
      if ActiveModel::SecurePassword.min_cost
        BCrypt::Engine::MIN_COST
      else
        BCrypt::Engine.cost
      end
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  # 永続セッションのためハッシュ化したトークンをデータベースに記憶します。
  def remember
    # selfを記述することで仮想のremember_token属性にUser.new_tokenで生成した「ハッシュ化されたトークン情報」を代入
    self.remember_token = User.new_token
    # update_attributeメソッドを使ってトークンダイジェストを更新
    update_attribute(:remember_digest, User.digest(remember_token))
    # update_attributesと違い（末尾にs）、こちらはバリデーションを素通りさせます
    # ユーザーのパスワードなどにアクセス出来ないため、このメソッドを用いてバリデーションを素通りさせる必要がある
  end
  
  # トークンがダイジェストと一致すればtrueを返します。
  def authenticated?(remember_token) # 真偽値が分かれば良いのでauthenticated?とします
    # ダイジェストが存在しない場合はfalseを返して終了します。
    return false if remember_digest.nil?
    # bcryptを使ってcookiesに保存されているremember_tokenがデータベースにあるremember_digestと一致することを確認します（トークン認証）
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
  
  # ユーザーのログイン情報を破棄します。
  def forget
    update_attribute(:remember_digest,nil)
  end
end
