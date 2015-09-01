class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, 
         :omniauthable, :database_authenticatable,
         :validatable

  after_create :register_hook


  def register_hook
    self.total_file_size = 0
    srh = SecureRandom.hex(24)
    self.user_directory = srh if User.find_by_user_directory(srh).nil?
    
    if self.save
      Dir.mkdir "public/directories/#{self.user_directory}"
      #json_file = File.new("public/directories/#{self.user_directory}/songs.json", "w+")
      #json_file.close
      FileUtils.copy("public/directories/default/defaultImg.png", "public/directories/#{self.user_directory}")

    end

  end
end
