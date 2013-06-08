module Bpmn
  module Utilities
    class SpecificationGenerator
      attr_reader :graph, :specification

      def initialize(graph_with_patterns)
        @graph = graph_with_patterns
      end

      def generate
        # TODO! iterate over the graph and generate specification using data from matched_fragments and related patterns.
      end
    end
  end
end