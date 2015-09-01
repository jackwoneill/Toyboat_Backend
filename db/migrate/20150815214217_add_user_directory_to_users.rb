class AddUserDirectoryToUsers < ActiveRecord::Migration
  def change
    add_column :users, :user_directory, :string
  end
end
