module Bpmn
  module Graph
    class Connector < BaseElement
      TYPES = %i(sequence_flow message_flow association)

      attr_accessor :start_node, :end_node, :type

      def initialize(start_node: nil, end_node: nil, type: :sequence_flow, **options)
        raise ArgumentError "undefined start node" unless start_node
        raise ArgumentError "undefined end node" unless end_node
        raise ArgumentError "undefined connector type" unless TYPES.include?(type)

        super(options)
        @start_node = start_node
        @end_node = end_node
        @type = type
      end

      def inspect
        "Connector##{ref_id} from:#{start_node.inspect} to:#{end_node.inspect}"
      end
    end
  end
end