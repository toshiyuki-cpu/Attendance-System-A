class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
#コントローラでヘルパーを使いたい場合はモジュールを読み込ませる必要があるが、
#全コントローラの親クラスであるapplication_controller.rbにこのモジュールを読み込ませることで、
#どのコントローラでもヘルパーに定義したメソッドが使えるようになりる
end
