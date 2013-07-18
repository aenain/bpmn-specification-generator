# WP3
module Bpmn
  module Pattern
    class Synchronization < Base
      DIRECTION = :back
      ARGUMENT_COUNT = 3

      def match(node)
        match_version_1(node) || match_version_2(node)
      end

      private

      def match_version_1(node)
        node_d = node
        return unless pass_conditions?(node_d, kind: %i(matched_fragment activity task)) &&
                      has_back_connections?(node_d, count: 1, conditions: { kind: [:sub_process] })

        connection = node_d.back_connections.first
        sub_process = connection.start_node
        return unless has_connections?(sub_process, count: 1) &&
                      has_end_nodes?(sub_process, count: 2) &&
                      has_nodes?(sub_process, count: 2)

        return unless sub_process.end_nodes.map do |node|
          pass_conditions?(node, kind: %i(matched_fragment activity task))
        end.all?

        build_fragment do |f|
          f.add_entry_node(sub_process)
          f.add_end_node(node_d)
          f.add_inner_connections(connection)
        end
      end

      def match_version_2(node)
        node_c = node
        return unless pass_conditions?(node_c, kind: %i(matched_fragment activity task)) &&
                      has_back_connections?(node_c, count: 1, conditions: { kind: [:gateway], type: [:parallel] })

        gateway = node_c.back_connections.first.start_node
        return unless has_back_connections?(gateway, count: 2, conditions: { kind: %i(matched_fragment activity task) }) &&
                      has_connections?(gateway, count: 1)

        node_a, node_b = gateway.back_connections.map(&:start_node)
        return unless has_connections?(node_b, count: 1) &&
                      has_connections?(node_a, count: 1)

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