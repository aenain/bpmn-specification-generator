module Bpmn
  module Utilities
    class PatternFinder
      attr_reader :graph, :pattern_name, :pending_queue, :visited_nodes, :nested_processes

      def initialize(graph, pattern_name)
        @graph            = graph
        @pattern_name     = pattern_name
        @pending_queue    = Queue.new
        @visited_nodes    = Set.new
        @nested_processes = Hash.new
      end

      # matched fragments will be passed to a block
      def run(&block)
        most_nested_processes.each do |process|
          find_in(process, &block)
        end

        find_in(graph, &block)
      end

      def node_changed(node)
        pending_queue.push(node)
      end

      def mark_visited(*nodes)
        nodes.flatten.each { |n| visited_nodes.add(n) }
      end

      private

      def find_in(graph_or_process, &block)
        start_nodes(graph_or_process).each do |node|
          pending_queue.push(node)
        end

        until pending_queue.empty?
          node = pending_queue.shift
          unless visited_nodes.include?(node)
            visited_nodes.add(node)

            matched_fragment = ::Bpmn::Pattern::Base.match(node, pattern_name)
            block.call(matched_fragment) if matched_fragment

            connections_method.bind(matched_fragment || node).call.map do |connection|
              connected_node = node_method.bind(connection).call
              pending_queue.push(connected_node) unless visited_nodes.include?(connected_node)
            end
          end
        end
      end

      def most_nested_processes
        find_nested_processes.sort.reverse.flat_map { |_, ps| ps }
      end

      def find_nested_processes(graph_or_process = @graph, nesting_level = 0)
        graph_or_process.sub_processes.each do |sub_process|
          (@nested_processes[nesting_level] ||= []) << sub_process
          find_nested_processes(sub_process, nesting_level + 1)
        end

        @nested_processes
      end

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

      def start_nodes(graph_or_process)
        find_back? ? graph_or_process.end_nodes : graph_or_process.entry_nodes
      end

      def find_back?
        ::Bpmn::Pattern::Base.direction(pattern_name) == :back
      end
    end
  end
end