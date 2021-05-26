class AddAdminToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :admin, :boolean, default: false # default: false デフォルトでは管理権限を持たないよう明示
  end
end
