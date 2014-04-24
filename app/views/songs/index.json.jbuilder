json.array!(@songs) do |song|
  json.extract! song, :id, :artist_name, :title, :genere_name, :duration, :price, :played_song, :country
  json.url song_url(song, format: :json)
end
