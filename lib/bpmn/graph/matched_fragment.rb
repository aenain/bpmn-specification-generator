module Bpmn
  module Graph
    class MatchedFragment < Node
      attr_accessor :inside_connections, :pattern
    end
  end
end