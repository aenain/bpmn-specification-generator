require 'active_support/inflector'

module Bpmn
  module Utilities
    class PatternExtractor
      ORDER = %i(sequence multiple_merge exclusive_choice multi_choice parallel_split simple_merge synchronization)

      attr_reader :graph

      def initialize(graph)
        @graph = graph
      end

      def extract
        fragment_matched = true

        while fragment_matched
          fragment_matched = false

          # FIXME
          ([:sequence] || ORDER).each do |pattern_name|
            finder = PatternFinder.new(graph, pattern_name)
            finder.run do |fragment|
              fragment_matched = true
              fragment.wrap
              finder.node_changed(fragment)
            end
          end
        end

        graph
      end
    end
  end
end