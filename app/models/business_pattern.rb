class BusinessPattern < ActiveRecord::Base
  attr_accessible :priority
  has_one :diagram, as: :graph_representable

  validates :diagram, :description, presence: true
end