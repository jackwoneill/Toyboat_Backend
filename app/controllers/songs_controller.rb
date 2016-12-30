require 'taglib'
require 'image_optim'
require 'fileutils'
require 'securerandom'

class SongsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_song, only: [:show, :edit, :update, :destroy]

  #Get the following info for each file uploaded
    # Title
    # Artist
    # Album
    # Genre
    # Track Number
    # Artwork
  #
  def getInfo(song)
    # BEGIN TAG DETECTION FOR TITLE, ARTIST, ETC. - NO ARTWORK #
    TagLib::FileRef.open('public' + song.file_url) do |fileref|
      unless fileref.null?
        tag = fileref.tag
        song.title = (tag.title if !tag.title.nil?) || "Unknown Title"
        song.artist = (tag.artist if !tag.artist.nil?) || "Unknown Artist"
        song.album = (tag.album if !tag.album.nil?) || "Unknown Album"
        song.genre = (tag.genre if !tag.genre.nil?) || ""
        song.track_number = (tag.track if !tag.track.nil?) || 0
        song.save
      end
    end
    # BEGIN EXISTING ARTWORK DETECTION

    # Check if the album already exists, if so, use same artwork
    # TODO Clean this up...this is horrific
    if Song.count > 1
      sl = Song.where(:directory => current_user.user_directory)
      if sl.count > 1
        sl1 = sl.select { |i| i.artist == song.artist }
        if sl1.count > 1
          sl2 = sl1.select {|i| i.album == song.album}
          if sl2.count > 1
            sl3 = sl2.select {|i| i.cover_art != "defaultImg.png"}
            if sl3.count > 1
              song.cover_art = sl3[0].cover_art
              return
            end
          end
        end
      end
    end
    #END EXISTING ARTWORK DETECTION

    TagLib::MPEG::File.open('public' + song.file_url) do |file|
      tag = file.id3v2_tag

      cover = tag.frame_list('APIC').first

      #Check if artwork ID3 tag exists
      if !cover.nil?
        picture = cover.picture

        file_name = 'public/directories/' + song.directory + '/' + File.basename(song.file_url, File.extname(song.file_url))

        #Create new file from attached cover artwork
        File.open(file_name + ".jpg", "wb") do |f|
          f.write(picture)
        end

        image = MiniMagick::Image.open(file_name + ".jpg")
        if image.dimensions != "[300, 300]"
          image.resize "300x300"
        end

        # Attempt to create unique file name
        new_file_name = "artworks-#{SecureRandom.uuid}"

        #Ensure file name is not already taken
        while Song.where(:cover_art => new_file_name).count != 0
          new_file_name = "artworks-#{SecureRandom.uuid}"
        end

        # Change images to PNG format
        image.format "png"
        image.write "public/a/#{new_file_name}.png"
        image_optim = ImageOptim.new()
        image_optim.optimize_image("public/a/#{new_file_name}.png")

        File.delete(file_name + ".jpg")

        bn = File.basename("#{song.file}", File.extname("#{song.file}"))

          song.cover_art = new_file_name + ".png"
          print song.cover_art
          song.save

          #Increase file size for song to account for new artwork file
          current_user.total_file_size += File.size("public/a/#{song.cover_art}")
          current_user.save
      else
        #If no artwork ID3 tag exists, set to default image
        song.cover_art = "defaultImg.png"
        song.save
      end
    end
  end

  def index
    if user_signed_in?
      @songs = Song.where(:directory => current_user.user_directory)
    end      
  end

  # GET /songs/1
  # GET /songs/1.json
  def show
    if @song.directory != current_user.user_directory
      redirect_to edit_song_path(@song)
    end
  end

  # GET /songs/new
  def new
    #@song = Song.new
    redirect_to songs_path
  end

  # GET /songs/1/edit
  def edit
    if @song.directory != current_user.user_directory
      redirect_to songs_url
    end
  end

  # POST /songs
  # POST /songs.json
  def create
    @song = Song.create(new_song_params)
    @song.locally_stored = false
    @song.directory = current_user.user_directory
    @song.file_size = 0
    getInfo(@song)
    # Why does this need to be moved? it shouldnt happen in the first place
    FileUtils.mv("public#{@song.file}", "public/directories/#{@song.directory}")
    handleFileSize(@song)
    @song.synced = false
    @song.save
    current_user.save
  end

  # PATCH/PUT /songs/1
  # PATCH/PUT /songs/1.json
  def update
    respond_to do |format|
      if @song.update(song_params)
        if !@song.artwork.blank?
          bn = File.basename("#{@song.file}", File.extname("#{@song.file}"))
          @song.cover_art = @song.artwork.to_s[3..-1]
          @song.artwork = nil
          current_user.total_file_size -= @song.file_size
          current_user.total_file_size += File.size("public/a/#{@song.cover_art}")


          handleFileSize(@song)
          @song.synced = false
          @song.save
          change_all_artwork(@song)
        end

        #@song.locally_stored = false
        #HANDLE CHANGES
        if @song.locally_stored == true 
          c = Change.where(:song_id => @song.id).where.not(:action => "create")
          if c.count != 0
            c.destroy_all
          end
          change = Change.create()
          change.user_directory = current_user.user_directory
          change.action = "update"
          change.song_id = @song.id
          change.save
          print("#{change.action}")
        end
        #END HANDLE CHANGES

        format.html { redirect_to songs_url, notice: 'Song was successfully updated.' }
        format.json { render :show, status: :ok, location: @song }
      else
        format.html { render :edit }
        format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /songs/1
  # DELETE /songs/1.json
  def destroy
    @song.destroy
    respond_to do |format|
      format.html { redirect_to songs_url, notice: 'Song was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  #def albums
   # @songs = Song.where{:directory => current_user.user_directory}
    #s1 = @songs.uniq{|s| s.album}
  #end
  def destroy_multiple
    songs = Song.find(params[:song_ids])
    songs.each do |s|
      if !s.cover_art.nil? && s.cover_art != "public/a/defaultImg.png"
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

      #HANDLE CHANGES
      if s.locally_stored == true   
        c = Change.where(:song_id => s.id)
        if c.count != 0
          c.destroy_all
        end

        change = Change.create()
        change.user_directory = current_user.user_directory
        change.action = "delete"
        change.song_id = s.id
        change.save
      end
      #HANDLE CHANGES

      current_user.save
      s.destroy
    end
    redirect_to songs_url
  end

  private 

    def handleFileSize(song)
      song.file_size = File.size("public#{song.file}")
      song.save
      current_user.total_file_size += song.file_size
      current_user.save

      if current_user.total_file_size > current_user.max_file_size

        if !song.cover_art.nil? && song.cover_art != "public/a/defaultImg.png"
          sl = Song.where(:directory => current_user.user_directory)
          sl1 = sl.select { |i| i.cover_art == song.cover_art } ####
          current_user.total_file_size -= File.size("public#{song.file}")
          print "sl1Count = #{sl1.count}"

        #if song is the only one using cover art, delete it
          if sl1.count == 1
            current_user.total_file_size -= File.size("public/a/#{song.cover_art}")
            File.delete("public/a/#{song.cover_art}")
          end
        end
        current_user.save
        song.destroy
      end
    end

    def change_all_artwork(song)

      Song.where(count > 1).where(:directory => current_user.user_directory)\
      
      if Song.count > 1
        sl = Song.where(:directory => current_user.user_directory)
        if sl.count > 1
          sl1 = sl.select { |i| i.artist == song.artist }
          if sl1.count > 1
            sl2 = sl1.select {|i| i.album == song.album}
            if sl2.count > 1
              sl2.each do |s|
                if s.album != "Unknown Album"
                  s.cover_art = song.cover_art
                  s.save
                end
              end
            end
          end
        end
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_song
      @song = Song.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def new_song_params
      params.require(:song).permit(:file)
    end

    def song_params
      params.require(:song).permit(:artwork, :title, :artist, :genre, :album, :synced)
    end
end
