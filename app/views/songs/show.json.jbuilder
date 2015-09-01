if current_user.user_directory == @song.directory
	json.extract! @song, :id, :created_at, :updated_at, :title, :artist, :album, :genre, :cover_art
end