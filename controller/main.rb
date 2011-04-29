class MainController < Ramaze::Controller
  layout '/layout'
  map '/'
  
  def index
  end
  
  deny_layout :join
  def join
    room, username = request[:room, :username].map{|x| h(x) }

    Juggernaut.publish( room, { :username => username, :message => "just joined this room", :action => :join } )

    return { :success => true }.to_json
  end

  deny_layout :send
  def send
    room, username, message = request[:room, :username, :message].map{|x| h(x) }
    
    Juggernaut.publish( room, { :username => username, :message => message, :action => :message } )
  end
end
