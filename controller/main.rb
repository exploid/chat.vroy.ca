GitHub::Markup.markup(:markdown, /md|mkdn?|mdown|markdown/) do |message|
  # See https://github.com/tanoku/redcarpet/blob/master/lib/redcarpet.rb for the options documentation
  Markdown.new(message, :autolink, :hard_wrap, :safelink).to_html
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
    
    return { :success => false }.to_json if message.empty?

    rendered = GitHub::Markup.render("message.markdown", message)

    Juggernaut.publish( room, { :username => username, :message => rendered, :action => :message } )
    
    return { :succes => true }.to_json
  end
end
