module Bpmn
  module Utilities
    class PatternFinder
      attr_reader :graph, :pattern_name, :pending_queue, :visited_nodes

      def initialize(graph, pattern_name)
        @graph          = graph
        @pattern_name   = pattern_name
        @pending_queue  = Queue.new
        @visited_nodes  = Set.new
      end

      # matched fragments will be passed to a block
      def run
        start_nodes.each do |node|
          pending_queue.push(node)
        end

        until pending_queue.empty?
          node = pending_queue.shift
          visited_nodes.add(node)

          matched_fragment = ::Bpmn::Pattern::Base.match(node, pattern_name)
          yield matched_fragment if matched_fragment

          connections_method.bind(matched_fragment || node).call.map do |connection|
            connected_node = node_method.bind(connection).call
            pending_queue.push(connected_node) unless visited_nodes.include?(connected_node)
          end
        end
      end

      def node_changed(node)
        pending_queue.push(node)
      end

      private

      def connections_method
        return @connections_method if @connections_method
        method_name = find_back? ? :back_connections : :connections
        @connections_method = ::Bpmn::Graph::Node.instance_method(method_name)
      end

      def node_method
        return @node_method if @node_method
        method_name = find_back? ? :start_node : :end_node
        @node_method = ::Bpmn::Graph::Connector.instance_method(method_name)
      end

      def start_nodes
        return @start_nodes if @start_nodes
        @start_nodes = find_back? ? graph.end_nodes : graph.entry_nodes
      end

      def find_back?
        ::Bpmn::Pattern::Base.direction(pattern_name) == :back
      end
    end
  end
end