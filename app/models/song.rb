class Song < ActiveRecord::Base
  mount_uploader :file, FileUploader
  mount_uploader :artwork, ArtworkUploader

end
