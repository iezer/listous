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
end
