# WP5
module Bpmn
  module Pattern
    class SimpleMerge < Base
      DIRECTION = :back

      def match(node)
        match_version_1(node) || match_version_2(node)
      end

      private

      def match_version_1(node)
        node_c = node
        return unless pass_conditions?(node_c, kind: %i(matched_fragment activity task)) &&
                      has_back_connections?(node_c, count: 2, conditions: { kind: %i(matched_fragment activity task) })

        back_connections = node_c.back_connections
        node_a, node_b = back_connections.map(&:start_node)
        return unless has_connections?(node_a, count: 1) &&
                      has_connections?(node_b, count: 1)

        ::Bpmn::Graph::MatchedFragment.new(pattern_name: :simple_merge).tap do |fragment|
          fragment.add_entry_nodes(node_a, node_b)
          fragment.add_end_node(node_c)
          fragment.add_inner_connections(back_connections)
        end
      end

      def match_version_2(node)
      end
    end
  end
end