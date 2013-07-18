require 'active_support/inflector'

module Bpmn
  module Utilities
    class PatternExtractor
      class NotFullyMatched < StandardError; end

      ORDER = %i(sequence multiple_merge parallel_split exclusive_choice multi_choice simple_merge synchronization)

      attr_reader :graph

      def initialize(graph)
        @graph = graph
      end

      def extract
        fragment_matched = true

        while fragment_matched
          fragment_matched = false

          ORDER.each do |pattern_name|
            finder = PatternFinder.new(graph, pattern_name)
            finder.run do |fragment|
              fragment_matched = true
              fragment.wrap

              finder.mark_visited(fragment.nodes)
              finder.node_changed(fragment)
            end
          end
        end

        ensure_graph_from_patterns

        graph
      end

      private

      def ensure_graph_from_patterns
        raise NotFullyMatched, "graph is not built only from defined patterns" unless graph.from_patterns_only?
      end
    end
  end
end