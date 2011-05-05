$online_users = {}
begin
  Thread.new do 
    Juggernaut.subscribe do |event, data|
      room = data["channel"]
      session_id = data["session_id"]
      username = (data["meta"] || {})["username"]
      return if username.nil?

      if event == :unsubscribe and $online_users[room].to_a.include?( username )
        $online_users[room] ||= []
        $online_users[room].delete( username )
        Juggernaut.publish( room, { :username => username, :action => :part, :online_users => $online_users[room] } )
      end
      
    end # Juggernaut
  end # Thread

rescue Exception => e
  # TODO: Implement fix to make sure that ramaze does not crash.
  puts e
  puts e.backtrace
end

class MainController < Ramaze::Controller
  layout '/layout'
  map '/'
  
  def index
  end
  
  deny_layout :join
  def join
    room, username = request[:room, :username].map{|x| h(x) }
    
    if $online_users[ room ].to_a.include?( username )
      message = "Username <b>#{username}</b> is already taken. Please choose another username and try again."
      return { :success => false, :message => message }.to_json
    end

    $online_users[room] ||= []
    $online_users[room] << username if !$online_users[room].include?( username )

    join_information = {
      :username => username,
      :action => :join,
      :online_users => $online_users[room]
    }
    Juggernaut.publish( room, join_information );
    
    return { :success => true, :online_users => $online_users[room] }.to_json
  end

  deny_layout :send
  def send
    room, username, message = request[:room, :username, :message].map{|x| h(x) }
    
    Juggernaut.publish( room, { :username => username, :message => message, :action => :message } )
  end
end
