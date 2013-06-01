require 'serialize_active_record'

class Diagram < ActiveRecord::Base
  serialize :graph, format: :marshal, gzip: true

  belongs_to :graph_representable, polymorphic: true

  def build_graph(raw_xml)
    # parse raw_xml
    self.graph = Bpmn::Graph::Graph.new
  end
end

# == Schema Information
#
# Table name: diagrams
#
#  id                       :integer          not null, primary key
#  title                    :string(255)
#  graph                    :binary
#  graph_representable_id   :integer
#  graph_representable_type :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  pattern_extraction       :boolean          default(FALSE)
#

