class User < ApplicationRecord #Userモデル
  before_save { self.email = email.downcase } #現在のメールアドレス（self.email）の値をdowncaseメソッドを使って小文字に変換
  
  validates :name, presence: true, length: { maximum: 50 }
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i #正規表現を代入している（値が変化する事がない為定数として定義）
  
  validates :email, presence: true, length: { maximum: 100 },
                    format: { with: VALID_EMAIL_REGEX }, #formatオプション（有効なメアドだけにマッチする）
                    uniqueness: true #一意性（他に同じデータがない）
  
  has_secure_password #パスワードをそのままの文字列ではなく、ハッシュ化した状態の文字列でデータベースに保存
                      # ハッシュ化とは、入力されたデータ（パスワード）を元に戻せないデータにする処理
                      
  validates :password, presence: true, length: { minimum: 6 }
end
