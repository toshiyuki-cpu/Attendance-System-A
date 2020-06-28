class User < ApplicationRecord #Userモデル
# before_saveとはActive Recordのコールバックメソッド
  before_save { self.email = email.downcase } #現在のメールアドレス（self.email）の値をdowncaseメソッドを使って小文字に変換
  
  validates :name, presence: true, length: { maximum: 50 } #presence 存在性
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i #正規表現を代入している（値が変化する事がない為定数として定義）
  
  validates :email, presence: true, length: { maximum: 100 },
                    format: { with: VALID_EMAIL_REGEX }, #formatオプション（有効なメアドだけにマッチする）
                    uniqueness: true #一意性（他に同じデータがない）
  
  has_secure_password #パスワードをそのままの文字列ではなく、ハッシュ化した状態の文字列でデータベースに保存
                      # ハッシュ化とは、入力されたデータ（パスワード）を元に戻せないデータにする処理
                      
  validates :password, presence: true, length: { minimum: 6 }
end

#has_secure_passwordを追加することで(bcryptと言うgemをインストール)
#1.ハッシュ化したパスワードを、データベースのpassword_digestというカラムに保存できるようになる。
#2.ペアとなる仮想的なカラムであるpasswordとpassword_confirmationが使えるようになる。さらに存在性と値が一致するかどうかの検証も追加される。
#3.authenticateメソッドが使用可能となる。
#このメソッドは引数の文字列がパスワードと一致した場合オブジェクトを返し、パスワードが一致しない場合はfalseを返す。
