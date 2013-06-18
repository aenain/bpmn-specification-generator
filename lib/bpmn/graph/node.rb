module Bpmn
  module Graph
    class Node < BaseElement
      attr_reader :connections, :back_connections

      def initialize(connections: [], back_connections: [], **options)
        super(**options)
        @connections = connections
        @back_connections = back_connections
      end

      def connect_with(node, **connector_options)
        connection = Connector.new(start_node: self, end_node: node, **connector_options)
        add_connection(connection)
        node.add_back_connection(connection)

        connection
      end

      def forward_nodes
        connections.map(&:end_node)
      end

      def back_nodes
        back_connections.map(&:start_node)
      end

      def inspect
        "#{self.class.name}##{ref_id}"
      end

      %i(connection back_connection).each do |connection|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def add_#{connection}(connection)             # def add_connection(connection)
            @#{connection}s << connection               #   @connections << connection
          end                                           # end

          def remove_#{connection}s                     # def remove_connections
            connections = @#{connection}s.dup           #   connections = @connections.dup
            @#{connection}s.clear                       #   @connections.clear
            connections                                 #   connections
          end                                           # end

          def remove_#{connection}(connection)          # def remove_connection(connection)
            @#{connection}s.delete(connection)          #   @connections.delete(connection)
          end                                           # end
        RUBY
      end
    end
  end
end