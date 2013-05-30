require 'json'
require 'jsonify'

# example of building json from graph
# json = Jsonify::Builder.pretty do |json|
#   json.graph do
#     node = graph.first_node
#     connected_nodes = node.connections.map(&:end_node)

#     json.nodes([node] + connected_nodes) do |node|
#       json.tag! :class, node.class.name.demodulize
#       json.type node.type if node.respond_to?(:type)
#       json.label node.representation.label
#       json.position node.representation.position
#     end
#   end
# end
module Bpmn
  class VisualizationSerializer

  end
end