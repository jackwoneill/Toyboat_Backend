class AddDirectoryToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :directory, :string
  end
end
