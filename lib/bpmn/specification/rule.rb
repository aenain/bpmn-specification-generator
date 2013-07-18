module Bpmn
  module Specification
    class Rule
      attr_reader :formula, :argument_names

      def initialize(formula)
        @formula = formula
        @argument_names = @formula.scan(/:f\d+/)
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