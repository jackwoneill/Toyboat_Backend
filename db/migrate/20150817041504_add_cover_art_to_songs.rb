class AddCoverArtToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :cover_art, :string
  end
end
