module Bpmn
  module Graph
    class Activity < Task
      attr_accessor :boundary_events
    end
  end
end