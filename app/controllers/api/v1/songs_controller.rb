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

      
    end
  end
end