class Api::V1::SongsController < Api::V1::BaseController
  def index
    #expose Changes.all
    expose Song.where(:directory => current_user.user_directory).where(:locally_stored => false)
  end

  def syncWithWeb
    expose Song.where(directory: current_user.user_directory).where(synced: false)
  end

  def setInRealm
    songs = Song.where(:directory => current_user.user_directory).where(:locally_stored => false)
    songs.each { |s| s.locally_stored = true }
    songs.each { |s| s.save }
  end

  def setNotInRealm
    songs = Song.where(:directory => current_user.user_directory)
    songs.each { |s| s.locally_stored = false }
    songs.each { |s| s.save }
  end

  def show
    if params[:id] == "setInRealm"
      songs = Song.where(:directory => current_user.user_directory)
      songs.each { |s| s.locally_stored = true }
      songs.each { |s| s.save }
      return
    end
    if params[:id] == "setNotInRealm"
      songs = Song.where(:directory => current_user.user_directory)
      songs.each { |s| s.locally_stored = false }
      songs.each { |s| s.save } 
      return
    end

    @song = Song.find(params[:id])

    print "#{@song.title}"
    expose @song
  end

  def destroy
    s = Song.find(params[:id])
    print(s.cover_art)
    if !s.cover_art.nil? && s.cover_art != "defaultImg.png"
      sl = Song.where(:directory => current_user.user_directory)
      sl1 = sl.select { |i| i.cover_art == s.cover_art } ####
      current_user.total_file_size -= File.size("public#{s.file}")
      print "sl1Count = #{sl1.count}"

      #if song is the only one using cover art, delete it
      if sl1.count == 1
        current_user.total_file_size -= File.size("public/a/#{s.cover_art}")
        File.delete("public/a/#{s.cover_art}")
      end
    end
    current_user.save
    s.destroy
    s.destroy
  end
end