require 'serialize_active_record'

class Diagram < ActiveRecord::Base
  serialize :graph, format: :marshal, gzip: true
  serialize :visualization, format: :marshal, gzip: true

  belongs_to :business_model

  def build_graph(raw_xml)
    self.graph = Bpmn::XmlParser.new(raw_xml).parse
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

