module Bpmn
  module Graph
    class Node < BaseElement
      attr_accessor :connections, :back_connections

      def initialize(connections: [], back_connections: [], **options)
        super(options)
        @connections = connections
        @back_connections = back_connections
      end

      def connect_with(node, **connector_options)
        connection = Connector.new(start_node: self, end_node: node, **connector_options)
        @connections << connection
        node.back_connections << connection

        connection
      end
    end
  end
end