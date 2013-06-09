module Bpmn
  module Graph
    class MatchedFragment < Node
      include ::Bpmn::Graph::Building
      include ::Bpmn::Graph::Wrapping

      attr_reader :pattern_name, :inner_nodes, :inner_connections

      def initialize(pattern_name: nil, connections: [], back_connections: [], **options)
        super(connections: connections, back_connections: back_connections, **options)
        @pattern_name = pattern_name
        @inner_nodes = []
        @inner_connections = []
      end

      def nodes
        entry_nodes + inner_nodes + end_nodes
      end

      def add_inner_connections(*connections)
        @inner_connections.concat connections.flatten
      end

      def add_inner_connection(connection)
        @inner_connections << connection
      end

      def add_inner_nodes(*nodes)
        @inner_nodes.concat nodes.flatten
      end

      def add_inner_node(node)
        @inner_nodes << node
      end

      def inspect
        "MatchedFragment entry_nodes:[#{entry_nodes.map(&:inspect).join(',')}] end_nodes:[#{end_nodes.map(&:inspect).join(',')}] pattern:#{pattern_name}"
      end
    end
  end
end