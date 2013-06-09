module Bpmn
  module Graph
    class MatchedFragment < Node
      include ::Bpmn::Graph::Building
      include ::Bpmn::Graph::Wrapping
      include ::Bpmn::Graph::InnerStructuring

      attr_reader :pattern_name

      def initialize(pattern_name: nil, connections: [], back_connections: [], **options)
        super(connections: connections, back_connections: back_connections, **options)
        @pattern_name = pattern_name
      end

      def nodes
        entry_nodes | inner_nodes | end_nodes
      end

      def inspect
        "MatchedFragment entry_nodes:[#{entry_nodes.map(&:inspect).join(',')}] end_nodes:[#{end_nodes.map(&:inspect).join(',')}] pattern:#{pattern_name}"
      end
    end
  end
end