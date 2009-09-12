require 'pp'
require 'rubygems'
require 'twitter'

USERNAME = "listous"
PASSWORD = ""
  
module ListsHelper
  
  def owners()
    list_owners = Array.new  
    List.all.each do |list|
      #puts(list.owner)
      list_owners << list.owner
    end
    
    list_owners = list_owners.sort
    list_owners = list_owners.uniq
    return list_owners
  end
  
  #Return true if already processed
  def delete_tweet( list_name, owner, author, text, submitted )
    puts "in delete " + author + " " + list_name + " " + text + " " + submitted.to_s
    if list_name[0] == 64 # @ we don't want this in list names
      puts("Error @ sign in list name. Can't delete someone elses list.")
      return false
    end
    
    #Created a list but no more items
    if text == ""
      #Can't delete if no text. use delete_list
      return false
    end
    
    @list = List.find( :first, 
                       :conditions => { :name =>  list_name,
                                        :owner => owner } )
    if not @list
      #Error can't delete can't find list TODO
      return false
    end
    
    #Check if the item exists, since we assume the messages
    #come in chronological order, we can just break when
    #we find something.
    @item = Item.find( :first,
                       :conditions => { :author => author,
                                        :text   => text } ) 
    
    if @item == nil and owner == author
      @item = Item.find( :first,
                         :conditions => { :text   => text } ) 
    end
    
    if @item == nil
      @item = Item.find( :first,
      :conditions=> ["author = ? and text like ?", author, text + "%"] ) 
    end
    
    if @item == nil and owner == author
      @item = Item.find( :first,
                         :conditions=> ["text like ?", text + "%"]  )
    end
    
    #Clean up this search by using the submit time and the list name or ID TODO
    #TODO really need to check submit time to make sure it's the same message
    if @item
      if @item.deleted
        puts "error item already deleted"
        return true
      else
        puts "deleting item"
        @item.deleted = true
        @item.save
        return false
      end
    else
      puts "error can't find item to delete"
      #Error, can't find the item so don't delete
    end
    
    return false
  end
  
  def parseTweet( author, full_message, submitted )
    
    command = "insert"
    owner = author
    
    splitter = full_message.split( ' ', 3 )
    if splitter.size == 0
      return false
    end
    
    if splitter[0] == "delete"
      if (splitter.size < 3)
        puts "error in delete need at least 3 tokens; delete list_name item_Text"
        return false
      end
      command = "delete"
      #get rid of "delete " from the message
      #TODO better to delete 1 el from splitter array
      new_str = full_message[7...full_message.size]
      splitter = new_str.split( ' ', 3 )
    end
    
    if splitter.size == 1
      #Create an empty list
      list_name = splitter[0]
      
      if list_name[0] == 64 # @ sign
        puts "Error - list name can't have @ sign. confuses with twitter username."
        return false
      end
      
      text = ""
      puts "1 token - create empty list"
      
    elsif splitter.size == 2
      list_name = splitter[0]
      text = splitter[1]
      
      if list_name[0] == 64 # @ sign
        puts "Error - list name can't have @ sign. confuses with twitter username."
        return false
      end
      
    else  #implies we have at least 3 tokens
      if splitter[0][0] == 64 # 64 is '@'
        owner = splitter[0]
        #chop off the leading @
        owner = owner[1...owner.size]
        list_name = splitter[1]
        text = splitter[2]
        puts("someone elses list " + owner)
      else
        list_name = splitter[0]
        text = splitter[1] + ' ' + splitter[2]
        puts ("3 tokens author's list")
      end
    end
    
    list_name = list_name.downcase
    owner = owner.downcase
    author = author.downcase
    
    text.strip() #remove whitespace from ends
    
    if list_name[0] == 64 # @ we don't want this in list names
      puts("Error @ sign in list name")
      return false
    end
    
    if command == "delete"
      return delete_tweet( list_name, owner, author, text, submitted )
    else
      return insert( list_name, owner, author, text, full_message, submitted )
    end
  end
  
  #return true if found the item
  def insert( list_name, owner, author, text, full_message, submitted )
    # TODO Checking friendship existance requires oauth
    #    if owner != author and not base.friendship_exists?(owner, author)
    #      puts(owner + " does not follow " + author + ". Not adding list.")
    #    else
    #      puts (owner + " " + author + " are friends, adding to list.")
    #    end
    
    @list = List.find( :first, 
                       :conditions => { :name =>  list_name,
                                        :owner => owner } )
    
    if not @list
      
      #Don't allow creating a list for someone else.
      if owner != author
        puts (owner + " " + author + " " + list_name + " doesn't exist, not creating.")
        return false
      end
      
      @list = List.new({ "owner"       => owner,
                         "name"        => list_name,
                         "permission"  => "public" } )
      @list.save #TODO error handling here like in list create method
    end
    
    #Created a list but no more items
    if text == ""
      return false
    end
    
    #Check if the item exists, since we assume the messages
    #come in chronological order, we can just break when
    #we find something.
    @item = Item.find( :first,
                       :conditions => { :author => author,
                                        :text   => text,
                                        :submitted => submitted } ) 
    #Clean up this search by using the submit time and the list name or ID TODO
    #TODO really need to check submit time to make sure it's the same message
    if @item
      puts("Already saw this element before")
      return true
    end
    
    @item = @list.items.build( {  :author => author,
                                  :text => text,
                                  :fullMessage => full_message,
                                  :submitted => submitted } )
    @item.save #TODO error handling
    print "item saved"
    
    return false
  end
  
  def parseTweets( tweets, replies = false )
    tweets.each do |twit|
      if replies
        author = twit.user.screen_name
      else
        author = twit.sender.screen_name
      end
      
      full_message = twit.text
      submitted = DateTime.parse( twit.created_at )
      
      if replies
        #remove '@listous' if it's at the front.
        #don't process as a list item if @listous appears anywhere else
        if full_message[0...8] != "@listous"
          puts("ignoring reply since @listous not at front")
          next
        else
          puts("stripping @listous from front of reply")
          full_message = full_message[8...full_message.size]
        end
      end
      
      #If parseTweet returns true then we have seen the message
      #already, so we have seen all remaining messages and 
      # can stop processing.
      if parseTweet( author, full_message, submitted )
        break
      end   
    end
  end
  
  def check_friendship ( list_owner, list_editor )
    httpauth = Twitter::HTTPAuth.new("listous", "")
    base = Twitter::Base.new( httpauth )
    #base = Twitter::Base.new( Twitter::Search.new() )
    b = false
    puts "Checking friendship " + list_owner + " " + list_editor + " "
    begin
      b = base.friendship_exists?( list_owner, list_editor )
    rescue
      b = false
    end
    pp b
    return false
  end
  
  def pollTwitter()
    
    httpauth = Twitter::HTTPAuth.new( USERNAME, PASSWORD )
    base = Twitter::Base.new( httpauth )
    
    print "User Timeline"
    #pp base.user_timeline
    
    print "Direct Messages"
    dm = base.direct_messages
    
    pp dm
    parseTweets( dm )
    
    #print "Replies"
    replies = base.replies
    pp replies
    parseTweets( replies, true )    
    
    #print "User Info"
    #pp base.verify_credentials
  end
  
  # Return true if we've already processed the message
  # TODO this could be better
  def parse_user_mention ( author, owner, full_message, submitted, regexp )
    m = regexp.match( full_message )
    # TODO assert 2 matches
    if m
      list_name = m[1]
      text = m[2]
      return insert( list_name, owner, author, text, full_message, submitted )
    else
      #TODO error handling
    end
    return false
  end
  
  def create_ls_regexp( username )
    s = "\\A@" + username + " #LS_(\\w+) ([\\w\\W]+)"
    Regexp.new( s )
  end
  
  def pollMentions( username, regexp )
    name = "@" + username
    tweets = Twitter::Search.new(name).fetch().results
    
    tweets.each do |twit|
      author = twit.from_user
      owner = username
      #there's a to_user field but I think this may or may not be the username we want
      full_message = twit.text
      submitted = DateTime.parse( twit.created_at )
      
      if parse_user_mention( author, owner, full_message, submitted, regexp )
        break
      end
    end  
  end
  
  def send_dm( user, message )  
    httpauth = Twitter::HTTPAuth.new( USERNAME, PASSWORD )
    base = Twitter::Base.new( httpauth )
    base.direct_message_create( user, message )
  end
  
  def get_all_users_mentions()
    owners = owners()
    owners.delete( "listous" )
    owners.each do |owner|
      pollMentions( owner, create_ls_regexp( owner ) )
      
      if owner == "esh2chan"
        pollMentions( owner, /@esh2chan (http:\/\/edomame.com\/[\d]+) ([\w\W]+)/ )
      end
    end  
  end
end
