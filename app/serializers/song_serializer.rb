class SongSerializer < ActiveModel::Serializer
  attributes :id, :title, :artist, :album, :genre, :file, :cover_art
end
