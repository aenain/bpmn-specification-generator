require 'singleton'

module Bpmn
  module Pattern
    class Base
      include Singleton

      # nil or MatchedFragment
      def self.match(node, pattern_name)
        pattern_class(pattern_name).instance.match(node)
      end

      def self.direction(pattern_name)
        pattern_class(pattern_name).const_get(:DIRECTION)
      end

      def self.pattern_class(pattern_name)
        "bpmn/pattern/#{pattern_name}".camelize.constantize
      end

      # nil or MatchedFragment
      def match(node)

      end
    end
  end
end