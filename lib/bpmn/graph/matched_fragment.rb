module Bpmn
  module Graph
    class MatchedFragment < Node
      include ::Bpmn::Graph::Building
      include ::Bpmn::Graph::Wrapping

      attr_reader :pattern_name, :inner_nodes

      def initialize(pattern_name: nil, connections: [], back_connections: [], **options)
        super(connections: connections, back_connections: back_connections, **options)
        @pattern_name = pattern_name
        @inner_nodes = []
      end

      def add_inner_node(node)
        inner_nodes << node
      end
    end
  end
end