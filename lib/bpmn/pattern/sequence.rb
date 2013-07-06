# WP1
module Bpmn
  module Pattern
    class Sequence < Base
      DIRECTION = :back
      RULES = [
        ':f1 => <>:f2',
        '~:f1 => ~<>:f2',
        '[]~(:f1 & :f2)'
      ]

      def match(node)
        connection = node.back_connections.first
        return unless has_back_connections?(node, count: 1, conditions: { kind: %i(start_event intermediate_event activity task matched_fragment) }) &&
                      has_connections?(connection.start_node, count: 1, conditions: { kind: %i(end_event intermediate_event activity task matched_fragment) })

        ::Bpmn::Graph::MatchedFragment.new(pattern_name: :sequence).tap do |fragment|
          fragment.add_entry_node(connection.start_node)
          fragment.add_end_node(node)
          fragment.add_inner_connection(connection)
        end
      end
    end
  end
end