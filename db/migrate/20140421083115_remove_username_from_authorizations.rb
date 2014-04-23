class RemoveUsernameFromAuthorizations < ActiveRecord::Migration
  def change
    remove_column :authorizations, :username, :string
  end
end
