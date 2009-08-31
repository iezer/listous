# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def title(phrase, container=nil)
    @page_title = phrase
    content_tag(container, phrase) if container
  end

end
