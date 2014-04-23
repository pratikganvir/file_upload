class RemoveFieldsFromUsers < ActiveRecord::Migration
  def change
    remove_column :users ,:username
    remove_column :users , :location
    remove_column :users , :image
    remove_column :users , :about
  end
end
