#require '../helpers/listous.rb'
include ListsHelper

class ListsController < ApplicationController
  # GET /lists
  # GET /lists.xml
  def index
    if ENV['RAILS_ENV'] != 'test'
      pollTwitter
    end
    @lists = List.all
 
    @owners = Array.new  
    List.all.each do |list|
      puts(list.owner)
      @owners.push(list.owner)
    end
    
    @owners = @owners.sort
    @owners = @owners.uniq
    
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lists }
    end
  end

  def user
    @user = params[:id]
    
    if ENV['RAILS_ENV'] != 'test'
      #pollTwitter
      pollMentions( @user, create_ls_regexp( @user ) )
      
      if @user == "esh2chan"
        pollMentions( @user, /@esh2chan (http:\/\/edomame.com\/[\d]+) ([\w\W]+)/ )
      end
    end
    
    if params[:list] != nil
      @list_name = params[:list]
      @lists = List.find(:all, :conditions => { :owner => @user, :name => @list_name } )
    else
      @lists = List.find(:all, :conditions => { :owner => @user } )
    end
    #@lists = List.find("owner")
    #format.html { render :action => "user" }
  respond_to do |format|
    format.html 
    format.xml
    #format.xml { render :xml => @lists }
  end

  end
  
  def owners
    @owners = Array.new  
    List.all.each do |list|
      puts(list.owner)
      @owners.push(list.owner)
    end
    
    @owners = @owners.sort
    @owners = @owners.uniq
  end
  
  # GET /lists/1
  # GET /lists/1.xml
  def show
    @list = List.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @list }
    end
  end

  # GET /lists/new
  # GET /lists/new.xml
  def new
    @list = List.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @list }
    end
  end

  # GET /lists/1/edit
  def edit
    @list = List.find(params[:id])
  end

  # POST /lists
  # POST /lists.xml
  def create
    @list = List.new(params[:list])

    respond_to do |format|
      if @list.save
        flash[:notice] = 'List was successfully created.'
        format.html { redirect_to(@list) }
        format.xml  { render :xml => @list, :status => :created, :location => @list }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /lists/1
  # PUT /lists/1.xml
  def update
    @list = List.find(params[:id])

    respond_to do |format|
      if @list.update_attributes(params[:list])
        flash[:notice] = 'List was successfully updated.'
        format.html { redirect_to(@list) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /lists/1
  # DELETE /lists/1.xml
  def destroy
    @list = List.find(params[:id])
    @list.destroy

    respond_to do |format|
      format.html { redirect_to(lists_url) }
      format.xml  { head :ok }
    end
  end
  
end
