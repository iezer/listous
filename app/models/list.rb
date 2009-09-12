class List < ActiveRecord::Base
  validates_presence_of :owner
  validates_presence_of :name
  has_many :items
end
