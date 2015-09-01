class RemoveTotalFileSizeFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :total_file_size, :decimal
  end
end
