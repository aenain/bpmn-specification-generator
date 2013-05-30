module Bpmn
  module Graph
    class Activity < Node
      attr_accessor :boundary_events
    end
  end
end