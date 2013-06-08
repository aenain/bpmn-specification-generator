# WP7
module Bpmn
  module Pattern
    class MultipleMerge < Base
      DIRECTION = :back

      # A splits to B, C and merges in D
      def match(node)
        node_a = node
        return unless node_a.connections.count == 2

        node_b, node_c = node_a.connections.map(&:end_node)
        return unless node_b.connections.count == 1 &&
                      node_c.connections.count == 1 &&
                      node_b.connections.first.end_node == node_c.connections.first.end_node

        node_d = node_b.connections.first.end_node

        ::Bpmn::Graph::MatchedFragment.new(pattern_name: :multiple_merge).tap do |fragment|
          fragment.add_entry_node(node_a)
          fragment.add_end_node(node_d)
          fragment.add_inner_nodes(node_b, node_c)
          fragment.add_inner_connections(node_a.connections + node_b.connections + node_c.connections)
        end
      end
    end
  end
end