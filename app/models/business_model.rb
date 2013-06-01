require 'bpmn'

class BusinessModel < ActiveRecord::Base
  has_one :diagram, -> { where(pattern_extraction: false) }, as: :graph_representable
  has_one :diagram_with_patterns, -> { where(pattern_extraction: true) }, class_name: "Diagram", as: :graph_representable
  has_one :logical_specification, as: :specificable

  validates :diagram, :description, presence: true
end

# == Schema Information
#
# Table name: business_models
#
#  id          :integer          not null, primary key
#  description :string(255)
#  raw_xml     :text
#  created_at  :datetime
#  updated_at  :datetime
#

