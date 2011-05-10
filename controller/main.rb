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
