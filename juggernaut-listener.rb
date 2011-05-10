require "app"

begin
  Juggernaut.subscribe do |event, data|
    room_name = data["channel"]
    session_id = data["session_id"]
    username = (data["meta"] || {})["username"]
    return if username.nil?
      
    room = Room[:name => room_name]

    if event == :unsubscribe and room and room.has_user?( username )
      User[ :username => username ].part( room )
      Juggernaut.publish( room.name, { :username => username, :action => :part, :online_users => room.usernames } )
    end

  end # Juggernaut

rescue Exception => e
  # TODO: Implement fix to make sure that ramaze does not crash.
  puts e
  puts e.backtrace
end
