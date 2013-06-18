require 'active_support/inflector'

module Bpmn
  module Utilities
    class PatternExtractor
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

        graph
      end
    end
  end
end