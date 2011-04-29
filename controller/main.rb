# Juggernaut.subscribe do |event, data|
  # p event
  # p data
  # Juggernaut.publish( data["channel"], { :username => data["meta"]["username"], :action => "part" } )
# end

class MainController < Ramaze::Controller
  layout '/layout'
  map '/'
  
  def index
  end
  
  deny_layout :join
  def join
    room, username = request[:room, :username].map{|x| h(x) }

    Juggernaut.publish( room, { :username => username, :action => :join } )

    return { :success => true }.to_json
  end

  deny_layout :send
  def send
    room, username, message = request[:room, :username, :message].map{|x| h(x) }
    
    Juggernaut.publish( room, { :username => username, :message => message, :action => :message } )
  end
end
