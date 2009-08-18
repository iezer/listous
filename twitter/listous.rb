#require File.join(File.dirname(__FILE__), '..', 'lib', 'twitter')
#require File.join(File.dirname(__FILE__), 'helpers', 'config_store')
#require 'pp'

require 'pp'
require 'rubygems'
gem 'twitter'
require 'twitter' 

#config = ConfigStore.new("#{ENV['HOME']}/.twitter")
#httpauth = Twitter::HTTPAuth.new(config['email'], config['password'])

def parseTweets( tweets, replies = false )
  tweets.each do |twit|
    if replies
      author = twit.user.screen_name
    else
      author = twit.sender.screen_name
    end
    
    fullMessage = twit.text
    submitted = twit.created_at
    
    if replies
      #remove '@listous' if it's at the front.
      #don't process as a list item if @listous appears anywhere else
      if fullMessage[0...8] != "@listous"
        puts("ignoring reply since @listous not at front")
        next
      else
        puts("stripping @listous from front of reply")
        fullMessage = fullMessage[8...fullMessage.size]
      end
    end
    
    splitter = fullMessage.split( ' ', 3 )
    
    if splitter.size < 2
      print "skipping"
      next #todo error
       puts "1 token error"
    elsif splitter.size == 2
      owner = author
      list_name = splitter[0]
      text = splitter[1]
      puts "2 tokens"
    else  #implies we have 3 tokens
      if splitter[0][0] == 64 # 64 is '@'
        owner = splitter[0]
        #chop off the leading @
        owner = owner[1...owner.size]
        list_name = splitter[1]
        text = splitter[2]
        puts("someone elses list " + owner)
      else
        owner = author
        list_name = splitter[0]
        text = splitter[1] + ' ' + splitter[2]
        puts ("3 tokens author's list")
      end
    end
    
    list_name = list_name.downcase
    owner = owner.downcase
    author = author.downcase
 
    # TODO Checking friendship existance requires oauth
#    if owner != author and not base.friendship_exists?(owner, author)
#      puts(owner + " does not follow " + author + ". Not adding list.")
#    else
#      puts (owner + " " + author + " are friends, adding to list.")
#    end
    
    if list_name[0] == 64 # @ we don't want this in list names
      puts("Error @ sign in list name")
      next
    end
    
    @list = List.find( :first, 
                       :conditions => { :name =>  list_name,
                                        :owner => owner } )
                                           
    if not @list
      
      #Don't allow creating a list for someone else.
      if owner != author
        puts (owner + " " + author + " " + list_name + " doesn't exist, not creating.")
        next
      end
      
      @list = List.new({ "owner"       => owner,
                         "name"        => list_name,
                         "permission"  => "public" } )
      @list.save #TODO error handling here like in list create method
    end
    
    #Check if the item exists, since we assume the messages
    #come in chronological order, we can just break when
    #we find something.
    @item = Item.find( :first,
                       :conditions => { :author => author,
                                        :fullMessage   => fullMessage } ) 
    #Clean up this search by using the submit time and the list name or ID TODO
    if @item
      puts("Already say this element before")
      break
    end
    
    @item = @list.items.build( {  :author => author,
                                  :text => text,
                                  :fullMessage => fullMessage,
                                  :submitted => submitted } )
    @item.save #TODO error handling
    print "item saved"
  end
end

httpauth = Twitter::HTTPAuth.new("listous", "t0r0nt0")
base = Twitter::Base.new(httpauth)

#print "User Timeline"
#pp base.user_timeline

print "Direct Messages"
pp base.direct_messages
parseTweets( base.direct_messages )

print "Replies"
pp base.replies
parseTweets( base.replies, true )

#print "User Info"
#pp base.verify_credentials