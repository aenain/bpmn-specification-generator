require 'singleton'

# module Bpmn
#   module Pattern
#     class Base
#       SPECIFICATION = ""

#       attr_accessor :specification, :node_to_match, :entry_nodes, :end_nodes, :connections

#       def initialize(node_to_match)
#         @node_to_match = node_to_match
#         @specification = SPECIFICATION

#         @entry_nodes = []
#         @end_nodes = []
#         @connections = []
#       end

#       # true or false
#       def match?
#         false
#       end
#     end
#   end
# end

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