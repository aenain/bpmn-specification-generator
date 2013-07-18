# WP5
module Bpmn
  module Pattern
    class SimpleMerge < Base
      DIRECTION = :back
      ARGUMENT_COUNT = 3

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

        build_fragment do |f|
          f.add_entry_nodes(node_a, node_b)
          f.add_end_node(node_c)
          f.add_inner_connections(back_connections)
        end
      end

      def match_version_2(node)
        node_c = node
        return unless pass_conditions?(node_c, kind: %i(matched_fragment activity task)) &&
                      has_back_connections?(node_c, count: 1, conditions: { kind: [:gateway], type: [:exclusive_data] })

        gateway = node_c.back_connections.first.start_node
        return unless has_back_connections?(gateway, count: 2, conditions: { kind: %i(matched_fragment activity task) }) &&
                      has_connections?(gateway, count: 1)

        node_a, node_b = gateway.back_connections.map(&:start_node)
        return unless has_connections?(node_a, count: 1) &&
                      has_connections?(node_b, count: 1)

        build_fragment do |f|
          f.add_entry_nodes(node_a, node_b)
          f.add_inner_node(gateway)
          f.add_end_node(node_c)
          f.add_inner_connections(gateway.back_connections + gateway.connections)
        end
      end
    end
  end
end