class AddTotalFileSizeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :total_file_size, :integer
  end
end
