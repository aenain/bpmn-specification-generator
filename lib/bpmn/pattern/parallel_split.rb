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

        ::Bpmn::Graph::MatchedFragment.new(pattern_name: :parallel_split).tap do |fragment|
          fragment.add_entry_node(node_a)
          fragment.add_end_node(sub_process)
          fragment.add_inner_connections(connection)
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