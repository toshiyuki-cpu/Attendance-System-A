# coding: utf-8

# 管理者の作成
User.create!(name: "管理者",
             email: "sample@email.com",
             role: 'admin',
             password: "password",
             password_confirmation: "password",
             admin: true) #最初のユーザーだけadmin属性をtrueに設定

# 上司Aの作成
User.create!(name: "上長A",
             email: "superior-a@email.com",
             role: 'superior',
             password: "password",
             password_confirmation: "password")
             
# 上司Bの作成
User.create!(name: "上長B",
             email: "superior-b@email.com",
             role: 'superior',
             password: "password",
             password_confirmation: "password")
             
# 上司Cの作成
User.create!(name: "上長C",
             email: "superior-c@email.com",
             role: 'superior',
             password: "password",
             password_confirmation: "password")
             
20.times do |n|
  name  = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  password = "password"
  User.create!(name: name,
               email: email,
               role: 'employee',
               password: password,
               password_confirmation: password)
end