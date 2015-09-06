class RemoveAPIKeyFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :api_key, :string
  end
end
