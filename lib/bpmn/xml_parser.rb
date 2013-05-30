require 'nokogiri'

# parses xml and builds whole graph structure
module Bpmn
  class XmlParser
    attr_reader :raw, :xml, :graph

    def initialize(raw)
      @raw = raw
    end

    def parse
      @xml = Nokogiri::XML(raw)
      @graph = Graph.new

      # TODO!
      # build whole structure of nodes and connectors.
      # enclose structure inside of a default swimlane inside of a default pool.

      graph
    end
  end
end