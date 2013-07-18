# WP6
module Bpmn
  module Pattern
    class MultiChoice < Base
      DIRECTION = :forward
      ARGUMENT_COUNT = 3

      def match(node)
        match_version_1(node) || match_version_2(node)
      end

      private

      def match_version_1(node)
        # TODO! implement this using mini gates
      end

      def match_version_2(node)
        node_a = node
        return unless pass_conditions?(node_a, kind: %i(matched_fragment activity task)) &&
                      has_connections?(node_a, count: 1, conditions: { kind: [:gateway], type: [:inclusive] })

        gateway = node_a.connections.first.end_node
        return unless has_connections?(gateway, count: 2, conditions: { kind: %i(matched_fragment activity task) }) &&
                      has_back_connections?(gateway, count: 1)

        node_b, node_c = gateway.connections.map(&:end_node)
        return unless has_back_connections?(node_b, count: 1) &&
                      has_back_connections?(node_c, count: 1)

        build_fragment do |f|
          f.add_entry_node(node_a)
          f.add_inner_node(gateway)
          f.add_end_nodes(node_b, node_c)
          f.add_inner_connections(node_a.connections + gateway.connections)
        end
      end
    end
  end
end