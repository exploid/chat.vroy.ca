class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :username, type: String

  belongs_to :room

  def part( room )
    room.users.where(_id: self.id).delete_all
    # puts "Remove #{self.id} from #{room}"
    # Join[:room_id => room.id, :user_id => self.id].delete
  end
end
