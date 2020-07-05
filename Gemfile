source 'https://rubygems.org'

gem 'rails',        '~> 5.1.6'
gem 'rails-i18n' #日本語化や国際化では、rails-i18n gemを利用
gem 'bcrypt' #has_secure_passwordの為
gem 'faker' #サンプルユーザーを複数まとめてコマンド一発で作成する
gem 'bootstrap-sass'
gem 'will_paginate' #ページネーション機能を追加
gem 'bootstrap-will_paginate' #ページネーションのデザインをお手軽に良くする
gem 'puma',         '~> 3.7'
gem 'sass-rails',   '~> 5.0'
gem 'uglifier',     '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'jquery-rails'
gem 'turbolinks',   '~> 5'
gem 'jbuilder',     '~> 2.5'

group :development, :test do
  gem 'sqlite3'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows環境ではtzinfo-dataというgemを含める必要があります
# Mac環境でもこのままでOKです
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]