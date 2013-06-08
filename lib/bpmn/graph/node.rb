module Bpmn
  module Graph
    class Node < BaseElement
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

      %i(connection back_connection).each do |connection|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{connection}s                            # def connections
            if !@#{connection}s.empty?                  #   if !@connections.empty?
              @#{connection}s                           #     @connections
            elsif parent.respond_to?(:#{connection}s)   #   elsif parent.respond_to?(:connections)
              parent.#{connection}s                     #     parent.connections
            else                                        #   else
              @#{connection}s                           #     @connections
            end                                         #   end
          end                                           # end

          def add_#{connection}(connection)             # def add_connection(connection)
            @#{connection}s << connection               #   @connections << connection
          end                                           # end

          def remove_#{connection}(connection)          # def remove_connection(connection)
            @#{connection}s.delete(connection)          #   @connections.delete(connection)
          end                                           # end
        RUBY
      end
    end
  end
end