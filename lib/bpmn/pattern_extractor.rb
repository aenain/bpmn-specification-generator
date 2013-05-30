module Bpmn
  # recognizes patterns from the given list in the graph and marks nodes accordingly.
  class PatternExtractor
    attr_reader :graph, :patterns

    # patterns - list of graphs containing patterns
    def initialize(graph, patterns)
      @graph = graph
      @patterns = patterns
    end

    def extract
      # TODO! do the magic :D
      graph
    end
  end
end