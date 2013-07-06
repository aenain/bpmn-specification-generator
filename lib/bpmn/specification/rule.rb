module Bpmn
  module Specification
    class Rule
      attr_reader :formula

      def initialize(formula)
        @formula = formula
      end

      def substitute!(substitutions = {})
        substitutions.inject(formula) do |formula, (symbol, value)|
          formula.gsub!(/:#{symbol}/, value)
          formula
        end
      end

      def substitute(substitutions = {})
        Rule.new(formula.dup).tap do |rule|
          rule.substitute!(substitutions)
        end
      end

      def to_s
        formula
      end

      def ==(other)
        formula == other.formula
      end
    end
  end
end