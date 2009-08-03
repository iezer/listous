#! /usr/bin/ruby

#require '/Users/isaac/.gem/ruby/1.8/gems/twitter-0.6.13/lib/twitter'

require 'pp'

require 'rubygems'
gem 'twitter'
require 'twitter' 

if __FILE__ == $0

  print "hello"
  
#search = Twitter::Search.new.from('listous')
search = Twitter::Search.new.from('isaacezer')

puts '*'*50, 'First Run', '*'*50
search.each { |result| 
  pp result 
}

end