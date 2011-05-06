unless DB.table_exists? :users
  DB.create_table :users do
    primary_key :id
    String :username
    Timestamp :timestamp
  end
end

class User < Sequel::Model
  
  def join( room )
    Join.create(:room_id => room.id, :user_id => self.id)
  end

  def part( room )
    Join[:room_id => room.id, :user_id => self.id].delete
  end
end
