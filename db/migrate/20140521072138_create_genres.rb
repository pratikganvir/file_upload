class CreateGenres < ActiveRecord::Migration
  def change
    create_table :genres do |t|
      t.string :song_type

      t.timestamps
    end
  end
end
