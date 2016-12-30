class Api::V1::ChangesController < Api::V1::BaseController
  def index
    #expose Changes.all
    expose Change.where(:user_directory => current_user.user_directory)
  end

  def clear
    Change.where(:user_directory => current_user.user_directory).destroy_all
  end
end