class ChangeSerializer < ActiveModel::Serializer
  attributes :song_id, :action, :user_directory
end
