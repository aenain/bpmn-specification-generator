require 'nokogiri'
require 'active_support/inflector'
require 'pry-debugger'

# parses xml and builds whole graph structure
# TODO! when creating nodes for subprocess use create_node method on sub_process instead of graph
module Bpmn
  module Utilities
    class XmlParser
      PATTERNS = {
        float: /[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?/,
        integer: /[-+]?[0-9]+/,
        boolean: /true|false/
      }

      ELEMENT_TYPES = {
        node:       %i(start_event end_event task),
        event:      %i(start_event end_event),
        connector:  %i(sequence_flow)
      }

      attr_reader :raw, :xml, :graph

      def initialize(raw)
        @raw = raw
      end

      def parse
        @xml = Nokogiri::XML(raw)
        @graph = Bpmn::Graph::Graph.new

        parse_children(@xml.root) do |child, data|
          case data[:type]
          when :process       then parse_process(child, data)
          when :bpmn_diagram  then parse_bpmn_diagram(child, data)
          end
        end

        graph
      end

      private

      def parse_process(node, attrs)
        parse_children(node, priority_type: :node) do |child, data|
          case data[:type]
          when *ELEMENT_TYPES[:node]        then parse_node(child, data)
          when *ELEMENT_TYPES[:connector]   then parse_connector(child, data)
          end
        end
      end

      def parse_node(node, data)
        type = data.delete(:type)
        case type
        when *ELEMENT_TYPES[:event]         then create_node(type, data[:attrs]) # diverse it.
        when *ELEMENT_TYPES[:node]          then create_node(type, data[:attrs])
        end
      end

      def parse_connector(node, data)
        type = data.delete(:type)
        create_connector(type, data[:attrs])
      end

      def parse_bpmn_diagram(node, data)
        match_data = data[:attrs][:documentation].match(/imageableWidth=(?<width>#{PATTERNS[:float]});imageableHeight=(?<height>#{PATTERNS[:float]})/)
        position = if match_data
                     # orientation = 0 => horizontal.
                     { width: match_data[:height].to_f, height: match_data[:width].to_f }
                   else
                     { width: 100, height: 100 }
                   end

        @graph.create_representation(position: position, name: data[:attrs][:name])

        parse_children(node) do |child, data|
          case data[:type]
          when :bpmn_plane  then parse_bpmn_plane(child, data)
          end
        end
      end

      def parse_bpmn_plane(node, data)
        parse_children(node) do |child, data|
          case data[:type]
          when :bpmn_shape  then parse_bpmn_shape(child, data)
          when :bpmn_edge   then parse_bpmn_edge(child, data)
          end
        end
      end

      def parse_bpmn_shape(node, shape_data)
        parse_children(node) do |child, data|
          case data[:type]
          when :bounds
            bounds_attrs = { ref_id: shape_data[:attrs][:bpmn_element] }.merge(data[:attrs])
            parse_bpmn_bounds(child, { type: :bounds, attrs: bounds_attrs })
          end
        end
      end

      def parse_bpmn_edge(node, edge_data)
        parse_children(node) do |child, data|
          case data[:type]
          when :waypoint
            waypoint_attrs = { ref_id: edge_data[:attrs][:bpmn_element] }.merge(data[:attrs])
            parse_bpmn_waypoint(child, { type: :waypoint, attrs: waypoint_attrs })
          end
        end
      end

      def parse_bpmn_bounds(node, data)
        position = {
          top: data[:attrs][:y],
          left: data[:attrs][:x],
          width: data[:attrs][:width],
          height: data[:attrs][:height]
        }
        @graph.change_element_position(data[:attrs][:ref_id], position)
      end

      def parse_bpmn_waypoint(node, data)
        waypoint = {
          top: data[:attrs][:y],
          left: data[:attrs][:x]
        }
        @graph.add_connector_waypoint(data[:attrs][:ref_id], waypoint)
      end

      def create_node(type, attrs)
        @graph.create_node(type, {
          ref_id: attrs[:id],
          name: attrs[:name]
        })
      end

      def create_connector(type, attrs)
        @graph.create_connector({
          ref_id: attrs[:id],
          start_ref_id: attrs[:source_ref],
          end_ref_id: attrs[:target_ref],
          type: type
        })
      end

      def parse_children(node, priority_type: nil)
        children = node.children.map do |child|
          next unless child.elem? # ommit text nodes
          attrs = extract_attributes(child)
          type = child.name.underscore.to_sym

          [child, { type: type, attrs: attrs }]
        end.compact

        if priority_type
          prioritized_types = Set.new(ELEMENT_TYPES[priority_type])
          children = children.partition do |child, data|
            prioritized_types.include?(data[:type])
          end.flatten(1)
        end

        children.each do |child, data|
          yield child, data
        end
      end

      def extract_attributes(xml_node)
        xml_node.attributes.values.inject({}) do |hash, attr|
          value = parse_value(attr.value)
          hash[attr.name.underscore.to_sym] = value
          hash
        end
      end

      # parses string value and returns either float, integer, boolean or string
      def parse_value(value)
        case value
        when /\A#{PATTERNS[:float]}\z/    then value.to_f
        when /\A#{PATTERNS[:integer]}\z/  then value.to_i
        when /\A#{PATTERNS[:boolean]}\z/  then value == "true"
        else value
        end
      end
    end
  end
end