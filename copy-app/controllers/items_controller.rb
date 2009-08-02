class ItemsController < ApplicationController
  def index
    @list = List.find(params[:list_id]) 
    @items = @list.items 
  end

  def show
    @list = List.find(params[:list_id]) 
    @items = @list.items 
  end

  def new
    @list = List.find(params[:list_id]) 
    @items = @list.items 
  end

 def create
    @list = List.find(params[:list_id])
    @item = @list.items.build(params[:item])
    if @item.save
      redirect_to list_item_url(@list, @item)
    else
      render :action => "new"
    end
  end 
   
  def edit
    @list = List.find(params[:list_id]) 
    @items = @list.items 
  end

  def update
  @list = List.find(params[:list_id])
  @item = Item.find(params[:id])
  if @item.update_attributes(params[:item])
    redirect_to list_item_url(@list, @item)
  else
    render :action => "edit"
  end
  end

  def destroy
    @list = List.find(params[:list_id])
    @item = Item.find(params[:id])
    @item.destroy
    respond_to do |format|
      format.html { redirect_to list_items_path(@list) }
      format.xml { head :ok }
    end
  end  
end
