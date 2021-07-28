source 'https://rubygems.org'

gem 'annotate'
gem 'bcrypt' # has_secure_passwordの為
gem 'bootstrap-sass'
gem 'bootstrap-will_paginate' # ページネーションのデザインをお手軽に良くする
gem 'coffee-rails', '~> 4.2'
gem 'enumerize'
gem 'faker' # サンプルユーザーを複数まとめてコマンド一発で作成する
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'puma', '~> 3.7'
gem 'rails', '~> 5.1.6'
gem 'rails-i18n' # 日本語化や国際化では、rails-i18n gemを利用
gem 'roo' # csv import
gem 'rounding' # 時間を15分単位で丸める
gem 'sass-rails',   '~> 5.0'
gem 'turbolinks',   '~> 5'
gem 'uglifier',     '>= 1.3.0'
gem 'will_paginate' # ページネーション機能を追加

group :development, :test do
  gem 'better_errors' # エラー画面をわかりやすく整形してくれる
  gem 'binding_of_caller' # better_errorsの画面上にirb/pry(PERL)を表示する
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'pry-byebug' # binding.pry で止めたところからステップ実行ができる
  gem 'pry-rails' # binding.pry使えるようになる
  gem 'rubocop', require: false # 規定のフォーマットから違反している部分を示してくれる機能に加え、-aオプションで「簡単な違反は自動で修正」までしてくれるツール
  gem 'rubocop-rails', require: false #
  gem 'sqlite3'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :production do
  gem 'pg', '0.20.0'
end

# Windows環境ではtzinfo-dataというgemを含める必要があります
# Mac環境でもこのままでOKです
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
