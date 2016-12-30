class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, 
         :omniauthable, :database_authenticatable,
         :validatable

  after_create :register_hook

  # before_create do |doc|
  #   doc.api_key = doc.generate_api_key
  # end

  def register_hook
    self.total_file_size = 0
    srh = SecureRandom.hex(24)
    self.user_directory = srh if User.find_by_user_directory(srh).nil?
    
    if self.save
      Dir.mkdir "public/directories/#{self.user_directory}"
    end

  end


  def generate_authentication_token
    loop do
      self.authentication_token = SecureRandom.hex
      return unless self.class.exists?(authentication_token: authentication_token)
    end

    save!

    authentication_token
  end

  # def generate_api_key
  # loop do
  #   token = SecureRandom.base64.tr('+/=', 'Qrt')
  #   break token unless User.exists?(api_key: token).any?
  # end
 #end
end
