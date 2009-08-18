module ListsHelper

  def owners()
    list_owners = []  
    List.each do |list|
      list_owners.push (list.owner)
    end
    
    list_owners = list_owners.sort
    list_owners = list_owners.unique
    
    return list_owners
  end

end
