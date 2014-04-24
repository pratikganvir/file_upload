class CreateSongs < ActiveRecord::Migration
  def change
    create_table :songs do |t|
      t.string :artist_name
      t.string :title
      t.string :genere_name
      t.time :duration
      t.float :price
      t.integer :played_song
      t.string :country

      t.timestamps
    end
  end
end
