class AddFileSizeToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :file_size, :integer
  end
end
