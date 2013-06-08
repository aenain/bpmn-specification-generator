require 'active_support/concern'
require 'active_support/inflector'
require 'pry-debugger'

module Bpmn
  module Graph
    module Building
      extend ActiveSupport::Concern

      included do
        # entry_nodes goes inside.
        # we assume that every sub_process has only one external entry point and one external way out.
        attr_reader :entry_nodes, :end_nodes, :sub_processes, :representation, :parent
      end

      def initialize(*args)
        super(*args)
        @sub_processes = []
        @entry_nodes = []
        @end_nodes = []
        @representation = nil
        @parent = nil
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
        lookup_element(ref_id, type: :connector).representation.add_waypoint(waypoint)
      end

      def create_node(type, **node_options)
        klass = "bpmn/graph/#{type}".to_s.camelize.constantize
        klass.new(**node_options).tap do |node|
          node.parent = self
          store_element(node.ref_id, node)
          case type
          when :start_event then add_entry_node(node)
          when :end_event   then add_end_node(node)
          when :sub_process then add_sub_process(node)
          end
        end
      end

      def create_connector(start_ref_id:"", end_ref_id:"", **connector_options)
        start_node, end_node = lookup_elements(start_ref_id, end_ref_id)
        start_node.connect_with(end_node, **connector_options).tap do |connector|
          store_element(connector.ref_id, connector)
        end
      end

      def add_entry_nodes(*nodes)
        entry_nodes.concat nodes.flatten
      end

      def add_entry_node(node)
        entry_nodes << node
      end

      def add_end_nodes(*nodes)
        end_nodes.concat nodes.flatten
      end

      def add_end_node(node)
        end_nodes << node
      end

      def add_sub_process(node)
        sub_processes << node
      end

      def store_element(ref_id, element)
        raise ArgumentError "ref_id can't be nil!" unless ref_id

        case element
        when Bpmn::Graph::Connector then ref_elements[:connectors][ref_id] = element
        else ref_elements[:nodes][ref_id] = element
        end
      end

      def lookup_elements(*ref_ids, type: :all)
        ref_ids.flatten.map { |id| lookup_element(id, type: type) }
      end

      def lookup_element(ref_id, type: :all)
        element = ref_elements_by_type(type)[ref_id]

        unless element
          sub_processes.each do |process|
            element = process.lookup_element(ref_id)
            break if element
          end
        end

        element
      end

      def get_elements(nested: false, type: :all)
        elements = ref_elements_by_type(type)

        elements.values.tap do |elements|
          sub_processes.each do |process|
            elements.concat process.get_elements(nested: nested, type: type)
          end if nested
        end
      end

      def ref_elements_by_type(type)
        case type
        when :all       then ref_elements[:nodes].merge(ref_elements[:connectors])
        when :node      then ref_elements[:nodes]
        when :connector then ref_elements[:connectors]
        end
      end

      private 

      def ref_elements
        @ref_elements ||= {
          nodes: {},
          connectors: {}
        }
      end
    end
  end
end