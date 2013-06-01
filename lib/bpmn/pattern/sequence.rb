module Bpmn
  module Pattern
    class Sequence < Base
      SPECIFICATION = "seq(:arg, :arg, :arg)" # TODO!

      def build_graph
        Graph::Graph.new.tap do |graph|
          activities = 3.times.map { graph.create_node(:activity) }
          graph.add_entry_node(activities[0])
          activities[0].connect_with(activities[1])
          activities[1].connect_with(activities[2])
        end
      end
    end
  end
end