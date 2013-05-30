class BusinessModel < ActiveRecord::Base
  has_one :diagram, as: :graph_representable, conditions: %("diagrams"."patterns_extracted" <> '1')
  has_one :diagram_with_patterns, class_name: "Diagram", conditions: %("diagrams"."patterns_extracted" = '1'), as: :graph_representable
  has_one :logical_specification, as: :logically_specificable

  validates :diagram, :description, presence: true
end