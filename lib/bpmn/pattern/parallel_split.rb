# WP2
module Bpmn
  module Pattern
    class ParallelSplit < Base
      DIRECTION = :forward

      def match(node)
        match_version_1(node) || match_version_2(node) || match_version_3(node)
      end

      private

      def match_version_1(node)
        # TODO! implement this
      end

      def match_version_2(node)
        node_a = node
        return unless has_connections?(node_a, count: 2)

        connections = node_a.connections
        node_b, node_c = connections.map(&:end_node)
        return unless has_back_connections?(node_b, count: 1) && has_back_connections?(node_c, count: 1)

        ::Bpmn::Graph::MatchedFragment.new(pattern_name: :parallel_split).tap do |fragment|
          fragment.add_entry_node(node_a)
          fragment.add_end_nodes(node_b, node_c)
          fragment.add_inner_connections(connections)
        end
      end

      def match_version_3(node)
        # TODO! implement this
      end
    end
  end
end