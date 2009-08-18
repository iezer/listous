class ItemsController < ApplicationController
  # GET /items
  # GET /items.xml
  def index
    #print "hello"
    #print params
    #@list = List.find(params[:list_id])
   # @list = List.find(1)
    #@items = @list.items 
    #@items = Item.all
    @list
    @items
    if params[:id]
      @list = List.find( params[:id] )
      #@list = List.find( :all, :name => params[:id] )

      @items = @list.items
    else
      @items = Item.all
    end
    
     
   # respond_to do |format|
   #   format.html # index.html.erb
   #   format.xml  { render :xml => @items }
   # end
  end

  # GET /items/1
  # GET /items/1.xml
  def show
   # @list = List.find(params[:list_id])
   # @items = @list.items.find(params[:id]) 
    @item = Item.find( params[:id] )
  #   @list = List.find( params[:item] [:list_id] )
    # @item = @list.items.build(params[:item])  
    # @items = Items.all

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @item }
    end
  end

  # GET /items/new
  # GET /items/new.xml
  def new
    #@list = List.find(params[:list_id])
    #@list = List.find(1)
    #@item = @list.items.build 
    # @items = Items.all
    @item = Item.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @items }
    end
  end

  # GET /items/1/edit
  def edit
    #@list = List.find(params[:list_id])
    @item = Item.find(params[:id])
    
    # @items = Items.all

#    @items = Items.find(params[:id])
  end

  # POST /items
  # POST /items.xml
  def create
    
     list_name =  params[:item] [:list_id]
     author =     params[:item] [:author]
     list_owner = params[:item] [:list_owner]
     if not list_owner
       list_owner = author
     end
     
     @list = List.find( :first, 
                        :conditions => { :name => list_name,
                                         :owner => list_owner } )
                                         
     #@list = List.find( params[:item] [:list_id] )
     
     if not @list
       @list = List.new({ "owner"       => params[:item] [:author],
                          "name"        => list_name,
                          "permission"  => "public" } )
       @list.save #TODO error handling here like in list create method
     end
     
     @item = @list.items.build(params[:item]) 
    #@items = Items.new(params[:items])

    respond_to do |format|
      if @item.save
        flash[:notice] = 'Items was successfully created.'
        format.html { redirect_to(@item) }
        format.xml  { render :xml => @item, :status => :created, :location => @item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @items.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /items/1
  # PUT /items/1.xml
  def update
     @list = List.find( params[:item] [:list_id] )
     
     
     @items = Item.find(params[:id])

    respond_to do |format|
      if @items.update_attributes(params[:items])
        flash[:notice] = 'Items was successfully updated.'
        format.html { redirect_to(@items) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @items.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.xml
  def destroy
    @items = Item.find(params[:id])
    @items.destroy

    respond_to do |format|
      format.html { redirect_to(items_url) }
      format.xml  { head :ok }
    end
  end
end
