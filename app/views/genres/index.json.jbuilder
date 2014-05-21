json.array!(@genres) do |genre|
  json.extract! genre, :id, :song_type
  json.url genre_url(genre, format: :json)
end
