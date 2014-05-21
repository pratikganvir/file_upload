class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.integer :user_id
      t.string :role_name , :default=>"User"

      t.timestamps
    end
  end
end
