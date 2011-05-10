begin
  Thread.new do 
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
    
    @user = User.find_or_create(:username => username)
    @room = Room.find_or_create(:name => room)

    begin
      @user.join( @room )
    rescue Exception => e
      if e.message.include?("Duplicate entry")
        message = "Username <b>#{username}</b> is already taken. Please choose another username and try again."
        return { :success => false, :message => message }.to_json
      end
    end

    online_users = @room.usernames
    Juggernaut.publish( room, {
      :username => username,
      :action => :join,
      :online_users => online_users
    } )
    
    return { :success => true, :online_users => online_users }.to_json
  end

  deny_layout :send
  def send
    room, username, message = request[:room, :username, :message].map{|x| h(x) }
    if !message.empty?
      message.gsub!("\n", "<br/>")
      Juggernaut.publish( room, { :username => username, :message => message, :action => :message } )
    end
  end
end
