module Bpmn
  module Specification
    class Specification
      attr_accessor :rule_sets

      def initialize
        @rule_sets = []
      end

      def << (rule_set)
        rule_sets << rule_set unless rule_set.empty?
      end

      def to_s
        "L = #{rule_sets.map(&:to_s).join(' | ')}"
      end
    end
  end
end