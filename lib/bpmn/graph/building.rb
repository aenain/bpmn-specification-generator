require 'active_support/concern'
require 'active_support/inflector'
require 'pry-debugger'

module Bpmn
  module Graph
    module Building
      extend ActiveSupport::Concern

      included do
        attr_reader :entry_nodes, :sub_processes, :representation
      end

      def initialize(*args)
        super(*args)
        @sub_processes = []
        @entry_nodes = []
        @representation = nil
      end

      def first_node
        entry_nodes.first
      end

      def create_representation(**representation_options)
        @representation = Representation.new(**representation_options)
      end

      def change_element_name(ref_id, name)
        lookup_element(ref_id).representation.name = name
      end

      def change_element_position(ref_id, position)
        lookup_element(ref_id).representation.update_position(position)
      end

      def add_connector_waypoint(ref_id, waypoint)
        lookup_element(ref_id).representation.add_waypoint(waypoint)
      end

      def create_node(type, **node_options)
        klass = "bpmn/graph/#{type}".to_s.camelize.constantize
        klass.new(**node_options).tap do |node|
          store_element(node.ref_id, node)
          add_entry_node(node) if type == :start_event
          add_sub_process(node) if type == :sub_process
        end
      end

      def create_connector(start_ref_id:"", end_ref_id:"", **connector_options)
        start_node, end_node = lookup_elements(start_ref_id, end_ref_id)
        start_node.connect_with(end_node, **connector_options).tap do |connector|
          store_element(connector.ref_id, connector)
        end
      end

      def add_entry_node(node)
        entry_nodes << node
      end

      def add_sub_process(node)
        sub_processes << node
      end

      def store_element(ref_id, element)
        raise ArgumentError "ref_id can't be nil!" unless ref_id
        ref_elements[ref_id] = element
      end

      def lookup_elements(*ref_ids)
        ref_ids.flatten.map { |id| lookup_element(id) }
      end

      def lookup_element(ref_id)
        element = ref_elements[ref_id]

        unless element
          sub_processes.each do |process|
            element = process.lookup_element(ref_id)
            break if element
          end
        end

        element
      end

      def ref_elements
        @ref_elements ||= {}
      end
    end
  end
end