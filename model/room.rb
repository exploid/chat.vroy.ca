unless DB.table_exists? :rooms
  DB.create_table :rooms do
    primary_key :id
    String :name, :unique => true
    Timestamp :timestamp
  end
end

class Room < Sequel::Model
  def users
    # TODO: Update to a join
    user_ids = Join.filter(:room_id => self.id).map(:user_id)
    return User.filter(:id => user_ids).all
  end
  
  # Return the usernames that are presently in the room in case insensitive alphabetical order.
  def usernames
    self.users.map{|user| user.username }.sort { |a,b| a.downcase <=> b.downcase }
  end

  def has_user?( username )
    # TODO: Use self.users if possible
    user_ids = Join.filter(:room_id => self.id).map(:user_id)
    return User.filter(:id => user_ids).filter(:username => username).count > 0
  end
end


