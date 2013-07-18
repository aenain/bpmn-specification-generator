module Bpmn
  module Specification
    class RuleSet
      attr_reader :rules

      def self.from_formulas(formulas)
        new formulas.map { |f| ::Bpmn::Specification::Rule.new(f) }
      end

      def initialize(rules = [])
        raise ArgumentError, "rules cannot be nil" unless rules
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

      def empty?
        rules.nil? || rules.empty?
      end

      def to_s
        "{ #{rules.map(&:to_s).join(', ')} }"
      end

      def ==(other)
        rules == other.rules
      end

      def count_arguments
        @argument_count ||= rules.map(&:argument_names).flatten.uniq.count
      end
    end
  end
end