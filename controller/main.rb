# See https://github.com/richleland/pygments-css for more pygments styles

GitHub::Markup.markup(:markdown, /md|mkdn?|mdown|markdown/) do |message|
  # Break under the username.
  #   * Bullet lists
  #   * Code blocks
  message = "&nbsp;\n\n#{message}" if message =~ /\A\* /m or message =~ /\A```/m
    
  # The first newline of a string should be considered a break.
  message.gsub!(/\A\n/, "<br/>") if message =~ /\A\n/m
  
  message.scan(/(```(\w*)\n(.*)```)/m).each do |full, lang, code|
    message.gsub!( full, Albino.colorize(code, lang) )
  end
  
  # See https://github.com/tanoku/redcarpet/blob/master/lib/redcarpet.rb for the options documentation
  Redcarpet.new(message, :autolink, :hard_wrap, :safelink, :strikethrough).to_html
end

class MainController < Ramaze::Controller
  map '/'
  
  set_layout 'layout' => [:index]
  def index
  end
  
  def join
    room, username = request[:room, :username].map{|x| h(x) }
    
    @user = User.find_or_create_by(:username => username)
    @room = Room.find_or_create_by(:name => room)

    @user.save
    @room.save

    @room.users.push @user

    online_users = @room.usernames
    Juggernaut.publish( room, {
      :username => username,
      :action => :join,
      :online_users => online_users
    } )
    
    return { :success => true, :online_users => online_users }.to_json
  end

  def send
    room, username = request[:room, :username].map{|x| h(x) }
    message = request[:message]
    
    return { :success => false }.to_json if message.empty?

    rendered = GitHub::Markup.render("message.markdown", message)

    Juggernaut.publish( room, { :username => username, :message => rendered, :action => :message } )
    
    return { :succes => true }.to_json
  end
end
