require 'bpmn'

class BusinessModel < ActiveRecord::Base
  has_one :diagram, -> { where(pattern_extraction: false) }
  has_one :diagram_with_patterns, -> { where(pattern_extraction: true) }, class_name: "Diagram"

  validates :diagram, presence: true

  def build_logical_specification
    definitions = Bpmn::Utilities::RuleParser.new(rule_definitions).parse
    self.logical_specification = ::Bpmn::Utilities::SpecificationGenerator.new(diagram_with_patterns.graph, definitions).generate.to_s
  end
end

# == Schema Information
#
# Table name: business_models
#
#  id                    :integer          not null, primary key
#  description           :string(255)
#  raw_xml               :text
#  created_at            :datetime
#  updated_at            :datetime
#  logical_specification :text
#

