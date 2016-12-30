class AddSyncedToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :synced, :boolean
  end
end
