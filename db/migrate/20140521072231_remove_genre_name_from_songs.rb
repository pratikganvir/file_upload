class RemoveGenreNameFromSongs < ActiveRecord::Migration
  def change
    remove_column :songs, :genere_name, :string
  end
end
