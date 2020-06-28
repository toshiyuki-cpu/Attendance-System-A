ActiveRecord::Schema.define(version: 20200626154922) do

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest" # このカラムを追加する事によりhas_secure_passwordが使える。ハッシュ化したパスワードを保存できる
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
