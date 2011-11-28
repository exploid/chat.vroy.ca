$LOAD_PATH.unshift("./")
require "app"

begin
  Juggernaut.subscribe do |event, data|
    room_name = data["channel"]
    session_id = data["session_id"]
    username = (data["meta"] || {})["username"]

    if !username.to_s.empty?
      room = Room.where(name: room_name).first

      if event == :unsubscribe and room and room.has_user?( username )
        User.where(username: username).first.part( room )
        Juggernaut.publish( room.name, { :username => username, :action => :part, :online_users => room.usernames } )
      end
    end

  end # Juggernaut

rescue Exception => e
  # TODO: Implement fix to make sure that ramaze does not crash.
  puts e
  puts e.backtrace
end
