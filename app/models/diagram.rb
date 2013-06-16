class Diagram < ActiveRecord::Base
  serialize :graph

  belongs_to :business_model

  def build_graph(raw_xml)
    self.graph = Bpmn::Utilities::XmlParser.new(raw_xml).parse
  end

  def prepare_visualization
    self.visualization = Bpmn::Utilities::VisualizationSerializer.new(graph).serialize
  end

  def extract_patterns
    self.graph = Bpmn::Utilities::PatternExtractor.new(graph).extract
  end
end

# == Schema Information
#
# Table name: diagrams
#
#  id                 :integer          not null, primary key
#  title              :string(255)
#  graph              :binary
#  business_model_id  :integer
#  created_at         :datetime
#  updated_at         :datetime
#  pattern_extraction :boolean          default(FALSE)
#  visualization      :binary
#

