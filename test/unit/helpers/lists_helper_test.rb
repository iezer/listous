require 'test_helper'

class ListsHelperTest < ActionView::TestCase

 
 def test_empty_list
    @list = List.find( :first, 
                       :conditions => { :name =>  "emptylist",
                                        :owner => "isaac" } )
    assert @list
    assert @list.items.size == 0   
  end
  
  def test_dm_add
    assert false == parseTweet( "isaacezer", "books The Tipping Point", "2009-08-01" )
    @list = List.find( :first, 
                       :conditions => { :name =>  "books",
                                        :owner => "isaacezer" } )
    assert @list
    
    @item = @list.items.find( :first,
                       :conditions => { :author => "isaacezer",
                                        :fullMessage   => "books The Tipping Point" } ) 
   assert @item
 end
 
end
