require 'active_support/concern'
require 'active_support/inflector'

module Bpmn
  module Graph
    module Building
      extend ActiveSupport::Concern

      included do
        attr_reader :entry_nodes, :ref_nodes, :sub_processes
      end

      def initialize(*args)
        super(*args)
        @sub_processes = []
        @entry_nodes = []
        @ref_nodes = {}
      end

      def first_node
        entry_nodes.first
      end

      def create_node(type, **node_options)
        klass = "bpmn/graph/#{type}".to_s.camelize.constantize
        klass.new(**node_options).tap do |node|
          store_node_reference(node.ref_id, node)
          add_entry_node(node) if type == :start_event
          add_sub_process(node) if type == :sub_process
        end
      end

      def add_entry_node(node)
        entry_nodes << node
      end

      def add_sub_process(node)
        sub_processes << node
      end

      def store_node_reference(ref_id, node)
        raise ArgumentError "Node#ref_id can't be nil!" unless ref_id
        @ref_nodes[ref_id] = node
      end

      def lookup_node(ref_id)
        node = @ref_nodes[ref_id]

        unless node
          sub_processes.each do |process|
            node = process.lookup_node(ref_id)
            break if node
          end
        end

        node
      end
    end
  end
end