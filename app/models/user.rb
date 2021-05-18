# == Schema Information
#
# Table name: users
#
#  id                         :integer          not null, primary key
#  admin                      :boolean          default(FALSE)
#  affiliation                :string
#  basic_time                 :datetime         default(Tue, 18 May 2021 08:00:00 JST +09:00)
#  basic_work_time            :datetime
#  designated_work_end_time   :datetime         default(Tue, 18 May 2021 18:00:00 JST +09:00)
#  designated_work_start_time :datetime         default(Tue, 18 May 2021 09:00:00 JST +09:00)
#  email                      :string
#  employee_number            :string
#  name                       :string
#  password_digest            :string
#  remember_digest            :string
#  role                       :string           default("employee"), not null
#  uid                        :string
#  work_time                  :datetime         default(Tue, 18 May 2021 07:30:00 JST +09:00)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
class User < ApplicationRecord #Userモデル
  # Userモデルからみた場合、Attendanceとの関係は1（User）対多（Attendance）
  # has_many ~と記述多数所持するため、複数形（attendances）となっている
  # ユーザーが削除された場合、関連する勤怠データも同時に自動で削除されるよう設定 dependent: :destroy
  
  extend Enumerize
  has_many :attendances, dependent: :destroy
  has_many :month_reports, dependent: :destroy
  
  enumerize :role, in: %i(admin superior employee), default: :employee, scope: true
  
  # 引数で受け取るユーザーを除いた上司を取得
  scope :superior_except_me, ->(user) { where.not(id: user).with_role(:superior) } 
  
  # 「remember_token」という仮想の属性を作成します。
  attr_accessor :remember_token
  
  # before_saveとはActive Recordのコールバックメソッド
  before_save { self.email = email.downcase } #現在のメールアドレス（self.email）の値をdowncaseメソッドを使って小文字に変換
  
  validates :name, presence: true, length: { maximum: 50 } #presence 存在性
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i # 正規表現を代入している（値が変化する事がない為定数として定義）
  
  validates :email, presence: true, length: { maximum: 100 },
                    format: { with: VALID_EMAIL_REGEX }, # formatオプション（有効なメアドだけにマッチする）
                    uniqueness: true # 一意性（他に同じデータがない）
                    
  validates :affiliation, length: { in: 2..30 }, allow_blank: true
  # inオプション「2文字以上かつ30文字以下」という検証を追加
  # allow_blank: true 値が空文字""の場合バリデーションをスルー
  
  validates :basic_time, presence: true
  
  validates :work_time, presence: true
  
  has_secure_password # パスワードをそのままの文字列ではなく、ハッシュ化した状態の文字列でデータベースに保存
                      # ハッシュ化とは、入力されたデータ（パスワード）を元に戻せないデータにする処理
                      
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  # has_secure_passwordを追加することで(bcryptと言うgemをインストール)
  # 1.ハッシュ化したパスワードを、データベースのpassword_digestというカラムに保存できるようになる。
  # 2.ペアとなる仮想的なカラムであるpasswordとpassword_confirmationが使えるようになる。さらに存在性と値が一致するかどうかの検証も追加される。
  # 3.authenticateメソッドが使用可能となる。
  # このメソッドは引数の文字列がパスワードと一致した場合オブジェクトを返し、パスワードが一致しない場合はfalseを返す。
  # allow_nil: trueはユーザー情報更新でパスワード入力しなくても更新できるメソッド
  
  def self.search(search) # ここでのself.はUser.を意味する 
    if search
      where(['name LIKE ?', "%#{search}%"]) #検索とnameの部分一致を表示。User.は省略
    else
      all # 全て表示。User.は省略
    end
  end

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
  
  # CSVインポート
  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      # インポートするデータに同じnameが見つかればそのレコードを呼び出し、見つかれなければ新しく作成する。
      user = User.find_by(name: row["name"]) || User.new
      # CSVファイルからデータを取得する
      user.attributes = row.to_hash.slice(*updatable_attributes)
      # !はCSVファイルでもインポート用ファイルではない、また異なるカラムを受信した時,例外を発生させる
      user.save!
    end
  end
  
  # CSVインポート時に受信するカラムを設定する
  def self.updatable_attributes
    ["name", "email", "affiliation", "employee_number", "uid", "basic_work_time", "designated_work_start_time", "designated_work_end_time", "admin", "role", "password"]
  end
end
