require 'nokogiri'
require 'active_support/inflector'

# parses xml and builds whole graph structure
module Bpmn
  class XmlParser
    PATTERNS = {
      float: /[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?/,
      integer: /[-+]?[0-9]+/,
      boolean: /true|false/
    }

    attr_reader :raw, :xml, :graph

    def initialize(raw)
      @raw = raw
    end

    def parse
      @xml = Nokogiri::XML(raw)
      @graph = Bpmn::Graph::Graph.new

      parse_children(@xml.root) do |child, attrs|
        case child.name
        when "process"      then parse_process(child, attrs)
        when "BPMNDiagram"  then parse_diagram(child, attrs)
        end
      end

      graph
    end

    private

    def parse_process(node, attrs)
      parse_children(node) do |child, attrs|
        case child.name
        when "startEvent"   then create_event(:start_event, attrs)
        when "task"         then create_task(attrs)
        when "endEvent"     then create_event(:end_event, attrs)
        when "sequenceFlow" then create_connector(:sequence_flow, attrs)
        end
      end
    end

    def parse_diagram(node, attrs)
      if /imageableWidth=(?<width>#{PATTERNS[:float]});imageableHeight=(?<height>#{PATTERNS[:float]})/ =~ attrs[:documentation]
        width, height = width.to_f, height.to_f
        # do the rest
      end
    end

    def parse_children(node)
      node.children.each do |child|
        next unless child.elem? # ommit text nodes
        attrs = extract_attributes(child)
        yield child, attrs
      end
    end

    def create_event(type, attrs)
      @graph.create_node(type, {
        ref_id: attrs[:id],
        name: attrs[:name]
      })
    end

    def create_task(attrs)
      @graph.create_node(:task, {
        ref_id: attrs[:id],
        name: attrs[:name],
        complete_quantity: attrs[:completion_quantity],
        for_completion: attrs[:is_for_compensation],
        start_quantity: attrs[:start_quantity]
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

    def extract_attributes(xml_node)
      xml_node.attributes.values.inject({}) do |hash, attr|
        value = parse_value(attr.value)
        hash[attr.name.underscore.to_sym] = value
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