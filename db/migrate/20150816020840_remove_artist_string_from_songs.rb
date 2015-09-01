class RemoveArtistStringFromSongs < ActiveRecord::Migration
  def change
    remove_column :songs, :artist_string, :string
  end
end
