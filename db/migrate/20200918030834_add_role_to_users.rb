class AddRoleToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :role, :string, default: 'employee', null: false, comment: '役割(社員/上司)'
  end
end
