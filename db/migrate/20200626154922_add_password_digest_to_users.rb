# has_secure_passwordの機能を利用する為、password_digestカラムを追加する
class AddPasswordDigestToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :password_digest, :string
  end
end
