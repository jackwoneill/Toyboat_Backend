module Api
  module V1
    class SongsController < ApplicationController
      respond_to :json

      def index
        respond_with Song.all
      end

      def show
        respond_with Song.find(params[:id])
      end

      def destroy
        respond_with @song do |format|
          @song.destroy
        end

        print "im trying to delete"
        # if !@song.cover_art.nil? && @song.cover_art != "public/a/defaultImg.png"
        #   sl = Song.where(:directory => current_user.user_directory)
        #   sl1 = sl.select { |i| i.cover_art == @song.cover_art }
        #   current_user.total_file_size -= File.size("public#{s.file}")

        #   if sl1.count == 1
        #     current_user.total_file_size -= File.size("public/a/#{s.cover_art}")
        #     File.delete("public/a/#{s.cover_art}")
        #   end
        #end
        #File.delete("public#{@song.file}")
        #@song.destroy
      end
    end
  end
end