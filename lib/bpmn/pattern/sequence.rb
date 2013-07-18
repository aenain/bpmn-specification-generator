# WP1
module Bpmn
  module Pattern
    class Sequence < Base
      DIRECTION = :back
      ARGUMENT_COUNT = 2

      def match(node)
        connection = node.back_connections.first
        return unless has_back_connections?(node, count: 1, conditions: { kind: %i(start_event intermediate_event activity task matched_fragment) }) &&
                      has_connections?(connection.start_node, count: 1, conditions: { kind: %i(end_event intermediate_event activity task matched_fragment) })

        build_fragment do |f|
          f.add_entry_node(connection.start_node)
          f.add_end_node(node)
          f.add_inner_connection(connection)
        end
      end
    end
  end
end