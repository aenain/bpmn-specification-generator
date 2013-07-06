module Bpmn
  module Utilities
    class SpecificationGenerator
      attr_reader :graph, :specification

      def initialize(graph_with_patterns)
        @graph = graph_with_patterns
        @specification = ::Bpmn::Specification::Specification.new
      end

      def generate
        fragment = @graph.entry_nodes.first
        append_rules(fragment)

        specification
      end

      def append_rules(fragment)
        fragment.nodes.each do |node|
          if node.kind_of?(::Bpmn::Graph::MatchedFragment)
            append_rules(node)
          end
        end

        entry_rules, end_rules = ::Bpmn::Pattern::Base.substitute_rules(fragment)
        specification << entry_rules
        specification << end_rules unless entry_rules == end_rules
      end
    end
  end
end