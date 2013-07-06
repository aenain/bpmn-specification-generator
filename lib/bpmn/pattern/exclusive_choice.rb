# WP4
module Bpmn
  module Pattern
    class ExclusiveChoice < Base
      DIRECTION = :forward
      RULES = []

      def match(node)
        node_a = node
        return unless pass_conditions?(node_a, kind: %i(matched_fragment activity task)) &&
                      has_connections?(node_a, count: 1, conditions: { kind: [:gateway], type: [:exclusive_data] })

        gateway = node_a.connections.first.end_node
        return unless has_connections?(gateway, count: 2, conditions: { kind: %i(matched_fragment activity task) }) &&
                      has_back_connections?(gateway, count: 1)

        node_b, node_c = gateway.connections.map(&:end_node)
        return unless has_back_connections?(node_b, count: 1) &&
                      has_back_connections?(node_c, count: 1)

        ::Bpmn::Graph::MatchedFragment.new(pattern_name: :exclusive_choice).tap do |fragment|
          fragment.add_entry_node(node_a)
          fragment.add_inner_node(gateway)
          fragment.add_end_nodes(node_b, node_c)
          fragment.add_inner_connections(node_a.connections + gateway.connections)
        end
      end
    end
  end
end