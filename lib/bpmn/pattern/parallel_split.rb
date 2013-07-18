# WP2
module Bpmn
  module Pattern
    class ParallelSplit < Base
      DIRECTION = :forward
      ARGUMENT_COUNT = 3

      def match(node)
        match_version_1(node) || match_version_2(node) || match_version_3(node)
      end

      private

      def match_version_1(node)
        node_a = node
        return unless pass_conditions?(node_a, kind: %i(matched_fragment activity task)) &&
                      has_connections?(node_a, count: 1, conditions: { kind: [:sub_process] })

        connection = node_a.connections.first
        sub_process = connection.end_node
        return unless has_back_connections?(sub_process, count: 1) &&
                      has_entry_nodes?(sub_process, count: 2) &&
                      has_nodes?(sub_process, count: 2)

        return unless sub_process.entry_nodes.map do |node|
          pass_conditions?(node, kind: %i(matched_fragment activity task))
        end.all?

        build_fragment do |f|
          f.add_entry_node(node_a)
          f.add_end_node(sub_process)
          f.add_inner_connections(connection)
          # TODO! define arguments for logical specification?
        end
      end

      def match_version_2(node)
        node_a = node
        return unless pass_conditions?(node_a, kind: %i(matched_fragment activity task)) &&
                      has_connections?(node_a, count: 2, conditions: { kind: %i(matched_fragment activity task) })

        connections = node_a.connections
        node_b, node_c = connections.map(&:end_node)
        return unless has_back_connections?(node_b, count: 1) &&
                      has_back_connections?(node_c, count: 1)

        build_fragment do |f|
          f.add_entry_node(node_a)
          f.add_end_nodes(node_b, node_c)
          f.add_inner_connections(connections)
        end
      end

      def match_version_3(node)
        node_a = node
        return unless pass_conditions?(node_a, kind: %i(matched_fragment activity task)) &&
                      has_connections?(node_a, count: 1, conditions: { kind: [:gateway], type: [:parallel] })

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