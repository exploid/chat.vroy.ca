# See https://github.com/richleland/pygments-css for more pygments styles

GitHub::Markup.markup(:markdown, /md|mkdn?|mdown|markdown/) do |message|
  # Bullet lists should appear under the username when the first element of a message.
  message = "&nbsp;\n\n#{message}" if message =~ /\A\* /m
  
  # The first newline of a string should be considered a break.
  message.gsub!(/\A\n/, "<br/>") if message =~ /\A\n/m
  
  message.scan(/(```(\w*)\n(.*)```)/m).each do |full, lang, code|
    message.gsub!( full, Albino.colorize(code, lang) )
  end
  
  # See https://github.com/tanoku/redcarpet/blob/master/lib/redcarpet.rb for the options documentation
  Redcarpet.new(message, :autolink, :hard_wrap, :safelink, :strikethrough).to_html
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
    room, username = request[:room, :username].map{|x| h(x) }
    message = request[:message]
    
    return { :success => false }.to_json if message.empty?

    rendered = GitHub::Markup.render("message.markdown", message)

    Juggernaut.publish( room, { :username => username, :message => rendered, :action => :message } )
    
    return { :succes => true }.to_json
  end
end
