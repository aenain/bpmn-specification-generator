require 'json'
require 'jsonify'

module Bpmn
  module Utilities
    class VisualizationSerializer
      attr_reader :graph, :json, :nodes, :connectors, :builder

      def initialize(graph)
        @graph      = graph
        @nodes      = Set.new
        @connectors = Set.new
      end

      def serialize
        gather_immediate_elements(graph)

        graph.most_nested_processes.reverse.each do |sub_process|
          gather_immediate_elements(sub_process)
        end

        @json = with_builder do
          serialize_canvas
          serialize_nodes
          serialize_connectors
        end
      end

      private

      def gather_immediate_elements(graph_or_process)
        @nodes.add(graph_or_process) if graph_or_process.parent

        matched_fragments, nodes = graph_or_process.get_elements(type: :node).partition do |node|
          node.kind_of?(::Bpmn::Graph::MatchedFragment)
        end

        # sub processes are handled in a special way
        nodes.reject! { |node| node.kind_of?(::Bpmn::Graph::SubProcess) }

        connectors = graph_or_process.get_elements(type: :connector)

        # added later are more general and should be first
        matched_fragments.reverse.each { |fragment| @nodes.add(fragment) }
        nodes.each { |node| @nodes.add(node) }
        connectors.each { |connector| @connectors.add(connector) }
      end

      def serialize_canvas
        builder.name graph.representation.name
        %i(width height).each do |canvas_attr|
          builder.tag! canvas_attr, graph.representation.position[canvas_attr]
        end
      end

      def serialize_nodes
        builder.nodes(nodes) do |node|
          serialize_common_element_part(node)

          builder.position do
            %i(top left width height).each do |position_attr|
              builder.tag! position_attr, node.representation.position[position_attr]
            end
          end
        end
      end

      def serialize_connectors
        builder.connectors(connectors) do |connector|
          serialize_common_element_part(connector)

          builder.waypoints(connector.representation.waypoints) do |waypoint|
            %i(top left).each do |waypoint_attr|
              builder.tag! waypoint_attr, waypoint[waypoint_attr]
            end
          end
        end
      end

      def serialize_common_element_part(element)
        builder.tag! :class, element.class.name.demodulize
        builder.type element.type if element.respond_to?(:type)
        builder.label element.representation.name
      end

      def with_builder
        Jsonify::Builder.pretty do |json|
          @builder = json
          begin
            yield
          ensure
            @builder = nil
          end
        end
      end
    end
  end
end