# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  username        :string(255)      not null
#  password_digest :string(255)      not null
#  session_token   :string(255)      not null
#  created_at      :datetime
#  updated_at      :datetime
#

class User < ActiveRecord::Base
  validates :username, :session_token, presence: true
  validates :password, length: { minimum: 4, allow_nil: true }
  validates :username, uniqueness: true
  
  after_initialize :ensure_session_token
  
  has_many(
    :gigs,
    class_name: "Gig",
    foreign_key: :creator_id,
    primary_key: :id
  )
  
  def password
    @password
  end 
  
  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end
  
  def generate_token
    SecureRandom.base64(16)
  end
  
  def is_password?(password)
    BCrypt::Password.new(self.password_digest).is_password?(password)
  end
  
  def self.find_by_credentials(username, password)
    user = User.find_by_username(username)
    return user if user && user.is_password?(password) 
    nil
  end
  
  def reset_session_token!
    self.session_token = generate_token
    self.save
    self.session_token
  end
  
  private
  
  def ensure_session_token
    self.session_token ||= generate_token
  end
  
end
