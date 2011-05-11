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

    # http://github.github.com/github-flavored-markdown/
    # in very clear cases, let newlines become <br /> tags
    message.gsub!(/^[\w\<][^\n]*\n+/) do |x|
      x =~ /\n{2}/ ? x : (x.strip!; x << "  \n")
    end

    # Autolinking - Modified version of the daringfireball regex to support autolinking
    # http://daringfireball.net/2009/11/liberal_regex_for_matching_urls
    message.gsub!(%r!\b(([\w-]+://?|www[.])[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s]|/)))/?!i) do |link|
      url = (link =~ %r!^https?://!i) ? link : "http://#{link}" # Ensure http is in the url part.
      %(<a href="#{url}" target="_blank">#{link}</a>)
    end

    message = GitHub::Markup.render("message.markdown", message)

    Juggernaut.publish( room, { :username => username, :message => message, :action => :message } )
    
    return { :succes => true }.to_json
  end
end
