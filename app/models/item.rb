class Item < ActiveRecord::Base
  validates_presence_of :author
  validates_presence_of :text
  validates_presence_of :fullMessage
  validates_presence_of :submitted
  belongs_to :list

end
