require 'json'
require 'jsonify'

module Bpmn
  class VisualizationSerializer
    attr_reader :graph, :json, :nodes, :connectors, :builder

    def initialize(graph)
      @graph = graph
      @builder = nil
      @nodes = []
      @connectors = []
    end

    def serialize
      @nodes, @connectors = graph.get_elements(nested: true).partition do |element|
        element.kind_of?(::Bpmn::Graph::Node)
      end

      @json = with_builder do
        serialize_canvas
        serialize_nodes
        serialize_connectors
      end
    end

    private

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

# raw_xml = File.read(File.expand_path("~/Downloads/model.bpmn20.xml")); graph = Bpmn::XmlParser.new(raw_xml).parse; serializer = Bpmn::VisualizationSerializer.new(graph)