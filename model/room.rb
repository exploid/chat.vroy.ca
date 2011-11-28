class Room
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name, type: String

  validates_uniqueness_of :name

  has_many :users

  # Return the usernames that are presently in the room in case insensitive alphabetical order.
  def usernames
    self.users.map{|user| user.username }.sort { |a,b| a.downcase <=> b.downcase }
  end

  def has_user?(username)
    return self.users.where(username: username).count > 0
  end
end


