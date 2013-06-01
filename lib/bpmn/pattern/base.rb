module Bpmn
  module Pattern
    class Base
      SPECIFICATION = ""

      attr_reader :graph, :specification

      def initialize
        @graph = build_graph
        @specification = self.class.SPECIFICATION
      end

      def build_graph
        raise NotImplementedError
      end
    end
  end
end