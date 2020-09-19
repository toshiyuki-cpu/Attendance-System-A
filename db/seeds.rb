# coding: utf-8

# 管理者の作成
User.create!(role: admin,
             name: "Admin User",
             email: "sample@email.com",
             password: "password",
             password_confirmation: "password",
             admin: true) #最初のユーザーだけadmin属性をtrueに設定

# 上司Aの作成
User.create!(role: superiorA,
             name: "SuperiorA",
             email: "superior-a@email.com",
             password: "password",
             password_confirmation: "password")
             
# 上司Bの作成             
User.create!(role: superiorB,
             name: "SuperiorB",
             email: "superior-b@email.com",
             password: "password",
             password_confirmation: "password")
             
20.times do |n|
  name  = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  password = "password"
  User.create!(role: employee,
               name: name,
               email: email,
               password: password,
               password_confirmation: password)
end