require 'yaml'
require 'hashie/mash'

module Bpmn
  module Utilities
    # reads file with rules defined for patterns
    class RuleParser
      class InvalidPatternFormulas < StandardError; end

      attr_reader :raw, :yaml, :definitions

      def initialize(raw)
        @raw = raw
        @definitions = Hashie::Mash.new
      end

      def parse
        @yaml = YAML.load(raw)

        @yaml.each do |pattern_name, formulas|
          define_pattern_formulas(pattern_name, formulas)          
        end

        @definitions
      end

      private

      def define_pattern_formulas(pattern_name, formulas)
        rule_set = ::Bpmn::Specification::RuleSet.from_formulas(formulas)
        ensure_pattern_arguments(pattern_name, rule_set)

        @definitions.send("#{pattern_name}=", rule_set)
      end

      def ensure_pattern_arguments(pattern_name, rule_set)
        expected_arguments = ::Bpmn::Pattern::Base.count_arguments(pattern_name)
        actual_arguments = rule_set.count_arguments

        unless actual_arguments == expected_arguments
          raise InvalidPatternFormulas, "expected #{expected_arguments} arguments for #{pattern_name}"
        end
      end
    end
  end
end