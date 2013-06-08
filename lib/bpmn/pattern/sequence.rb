# WP1
module Bpmn
  module Pattern
    class Sequence < Base
      DIRECTION = :back

      def match(node)
        connection = node.back_connections.first
        return unless has_one_back_connection?(node) && has_one_connection?(connection.start_node)

        ::Bpmn::Graph::MatchedFragment.new(pattern_name: :sequence).tap do |fragment|
          fragment.add_entry_node(connection.start_node)
          fragment.add_end_node(node)
          fragment.add_connection(connection)
        end
      end

      private

      def has_one_connection?(node)
        node.connections.count == 1
      end

      def has_one_back_connection?(node)
        node.back_connections.count == 1
      end
    end
  end
end