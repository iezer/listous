require 'test_helper'

class ListsHelperTest < ActionView::TestCase
  
  
  def test_empty_list
    @list = List.find( :first, 
                       :conditions => { :name =>  "emptylist",
                                        :owner => "isaac" } )
    assert @list
    assert @list.items.size == 0   
  end
  
  def test_insert_to_empty_list
    assert false == parseTweet( "isaacezer", "emptylist The Tipping Point", "2009-08-01" )
    @list = List.find( :first, 
                       :conditions => { :name =>  "emptylist",
                                        :owner => "isaacezer" } )
  end
  
  def test_create_new_list
    assert false == parseTweet( "isaacezer", "books The Tipping Point", "2009-08-01" )
    @list = List.find( :first, 
                       :conditions => { :name =>  "books",
                                        :owner => "isaacezer" } )
    assert @list
    
    @item = @list.items.find( :first,
                       :conditions => { :author => "isaacezer",
                                        :fullMessage   => "books The Tipping Point",
                                        :text => "The Tipping Point"} ) 
    assert @item
  end
  
  def test_create_empty_list
    assert false == parseTweet( "isaacezer", "music", "2009-08-01" )
    @list = List.find( :first, 
                       :conditions => { :name =>  "music",
                                        :owner => "isaacezer" } )
    assert @list
    assert @list.items.size == 0
    
  end
  
  def test_add_to_someone_elses_list
    assert false == parseTweet( "hyfen", "@isaacezer onelist jazz", "2009-08-01" )
    
    @list = List.find( :first, 
                       :conditions => { :name =>  "onelist",
                                        :owner => "isaacezer" } )
    assert @list
    assert @list.owner == "isaacezer"
    @item = @list.items.find( :first,
                       :conditions => { :author => "hyfen",
                                        :fullMessage   => "@isaacezer onelist jazz",
                                        :text => "jazz" } ) 
    assert @item
  end

  def test_add_to_someone_elses_list_not_exist
    assert false == parseTweet( "hyfen", "@isaacezer nolist jazz", "2009-08-01" )
    
    @list = List.find( :first, 
                       :conditions => { :name =>  "music",
                                        :owner => "isaacezer" } )
    assert_nil @list
  end

  def add_duplicate_diff_time_ok
    assert false == parseTweet( "isaacezer", "emptylist jazz", "2009-08-01" )
    assert false == parseTweet( "isaacezer", "emptylist jazz", "2009-08-02" )
    
    @list = List.find( :first, 
                       :conditions => { :name =>  "music",
                                        :owner => "isaacezer" } )
    assert_nil @list
  end

  def add_duplicate
    assert false == parseTweet( "isaacezer", "emptylist jazz", "2009-08-01" )
    assert true  == parseTweet( "isaacezer", "emptylist jazz", "2009-08-01" )
    
    @list = List.find( :first, 
                       :conditions => { :name =>  "music",
                                        :owner => "isaacezer" } )
    assert_nil @list
  end
  
  def test_delete
    assert false == parseTweet( "isaacezer", "books The Tipping Point", "2009-08-01" )
    assert false == parseTweet( "isaacezer", "books Blink", "2009-08-01" )

    @list = List.find( :first, 
                   :conditions => { :name =>  "books",
                                    :owner => "isaacezer" } )
    assert @list.items.size == 2

    assert @item
    assert false == parseTweet( "isaacezer", "delete books Blink", "2009-08-01" )
    @item = @list.items.find( :first,
               :conditions => { :author => "isaacezer",
                                :text => "Blink" } )

    assert true == @item.deleted
  end

  def test_delete_twice
    assert false == parseTweet( "isaacezer", "books Blink", "2009-08-01" )
    assert false == parseTweet( "isaacezer", "delete books Blink", "2009-08-01" )
    assert true  == @item.deleted
    assert true  == parseTweet( "isaacezer", "delete books Blink", "2009-08-01" )
    assert true  == @item.deleted
  end
  
  def test_delete_not_exist
    
  end
  
  def test_delete_no_item_text
    
  end
  
  def test_delete_non_owner
    assert false == parseTweet( "isaacezer", "books The Tipping Point", "2009-08-01" )
    assert false == parseTweet( "hyfen", "@isaacezer books Blink", "2009-08-01" )

    @list = List.find( :first, 
                   :conditions => { :name =>  "books",
                                    :owner => "isaacezer" } )
    assert @list.items.size == 2

    assert @item
    assert false == parseTweet( "hyfen", "delete @isaacezer books Blink", "2009-08-01" )
    @item = @list.items.find( :first,
               :conditions => { :author => "hyfen",
                                :text => "Blink" } )

    assert true == @item.deleted
  end

  def test_delete_non_owner_by_owner
    assert false == parseTweet( "isaacezer", "books The Tipping Point", "2009-08-01" )
    assert false == parseTweet( "hyfen", "@isaacezer books Blink", "2009-08-01" )

    @list = List.find( :first, 
                   :conditions => { :name =>  "books",
                                    :owner => "isaacezer" } )
    assert @list.items.size == 2

    assert @item
    assert false == parseTweet( "isaacezer", "delete books Blink", "2009-08-01" )
    @item = @list.items.find( :first,
               :conditions => { :author => "hyfen",
                                :text => "Blink" } )

    assert true == @item.deleted
  end
  
  def test_delete_non_owner1
    assert false == parseTweet( "isaacezer", "books The Tipping Point", "2009-08-01" )
    assert false == parseTweet( "isaacezer", "books Blink", "2009-08-01" )

    @list = List.find( :first, 
                   :conditions => { :name =>  "books",
                                    :owner => "isaacezer" } )
    assert @list.items.size == 2

    assert @item
    assert false == parseTweet( "hyfen", "delete @isaacezer books Blink", "2009-08-01" )
    @item = @list.items.find( :first,
               :conditions => { :author => "isaacezer",
                                :text => "Blink" } )

    assert false == @item.deleted
  end
  
  def test_delete_non_owner2
    assert false == parseTweet( "isaacezer", "books The Tipping Point", "2009-08-01" )
    assert false == parseTweet( "hyfen", "@isaacezer books Blink", "2009-08-01" )

    @list = List.find( :first, 
                   :conditions => { :name =>  "books",
                                    :owner => "isaacezer" } )
    assert @list.items.size == 2

    assert @item
    assert false == parseTweet( "esh2chan", "delete @isaacezer books Blink", "2009-08-01" )
    @item = @list.items.find( :first,
               :conditions => { :author => "hyfen",
                                :text => "Blink" } )

    assert false == @item.deleted
  end
  
  def test_delete_substring
    #Since tweets are max 140 chars, we may have to delete by matching only a subset
    assert false == parseTweet( "isaacezer", "books The Tipping Point", "2009-08-01" )
    assert false == parseTweet( "isaacezer", "delete @isaacezer books The Tipping", "2009-08-01" )
    
    @list = List.find( :first, 
                   :conditions => { :name =>  "books",
                                    :owner => "isaacezer" } )
                                    
    @item = @list.items.find( :first,
               :conditions => { :author => "isaacezer",
                                :text => "The Tipping Point" } )

    assert true == @item.deleted
    
  end
  
  def test_create_regexp1
    # Test basic create regexp
    r = create_ls_regexp( "isaacezer" )
    r2 = /\A@isaacezer #LS_(\w+) ([\w\W]+)/
    assert r == r2
  end

  def test_create_regexp2
    #Test match with simple message
    r = create_ls_regexp( "isaacezer" )
    s  = "@isaacezer #LS_book Blink"
    m = r.match( s )
    assert m
    assert m[1] == "book"
    assert m[2] == "Blink"
  end

  def test_create_regexp3
    #Test match with more complicated message
    r = create_ls_regexp( "isaacezer" )
    s  = "@isaacezer #LS_book_list123 hello world 635 blah htp://www..."
    m = r.match( s )
    assert m
    assert m[1] == "book_list123"
    assert m[2] == "hello world 635 blah htp://www..."
  end
  
  def test_create_regexp4
    #Test no match with incorrect syntax. must have _ (we can debate this later...)
    r = create_ls_regexp( "isaacezer" )
    s  = "@isaacezer #LSbook Blink"
    m = r.match( s )
    assert_nil m
  end

  def test_create_regexp5
    #Test only match if username appears at beginning of message. Here 1st char is space.
    r = create_ls_regexp( "isaacezer" )
    s  = " @isaacezer #LS_book Blink"
    m = r.match( s )
    assert_nil m
  end
  
  def test_create_regexp6
    # Test more complicated message with invalid char in list name
    r = create_ls_regexp( "isaacezer" )
    s  = "@isaacezer #LS_book_list123//: hello world 635 blah htp://www..."
    m = r.match( s )
    assert_nil m
  end
  
  def test_regex_esh2chan
    r = /@esh2chan (http:\/\/edomame.com\/[\d]+) ([\w\W]+)/
    s  = "@esh2chan http://edomame.com/123 hello world 635 blah htp://www..."
    m = r.match( s )
    assert m
    assert m[1] == "http://edomame.com/123"
    assert m[2] == "hello world 635 blah htp://www..."
  end
  
  def test_parse_mention1
    owner   = "isaacezer"
    author  = "hyfen"
    submitted = "2009-08-01"
    full_message = "@isaacezer #LS_onelist Blink"
    regexp = create_ls_regexp( owner )

    assert false == parse_user_mention( author, owner, full_message, submitted, regexp )  
    
    @list = List.find( :first, 
                   :conditions => { :name =>  "onelist",
                                    :owner => "isaacezer" } )
    assert @list
    @item = @list.items.find( :first,
               :conditions => { :author => "hyfen",
                                :text => "Blink" } )
    assert @item
    
    #Make sure returns true if it already saw it.
    assert parse_user_mention( author, owner, full_message, submitted, regexp )
  end
  
end