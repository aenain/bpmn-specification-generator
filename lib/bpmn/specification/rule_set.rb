module Bpmn
  module Specification
    class RuleSet
      attr_reader :rules

      def initialize(rules = [])
        @rules = rules
      end

      def substitute!(substitutions = {})
        rules.each do |rule|
          rule.substitute!(substitutions)
        end
      end

      def substitute(substitutions = {})
        RuleSet.new rules.map { |r| r.substitute(substitutions) }
      end

      def to_s
        "{ #{rules.map(&:to_s).join(', ')} }"
      end

      def ==(other)
        rules == other.rules
      end
    end
  end
end