# Represents whole business process model.
#
# Example of building from scratch:
# graph = Bpmn::Graph::Graph.new
# task_1 = graph.create_node(:task)
# task_1.create_representation(label: "Task 1", position: { top: 50, left: 20, width: 300, height: 100 })
#
# task_2 = graph.create_node(:task)
# task_2.create_representation(label: "Task 2", position: { top: 100, left: 200, width: 300, height: 100 })
#
# start_event = graph.create_node(:start_event, type: :message, id: "20")
# start_event.create_representation(label: "S", position: { top: 0, left: 0, width: 30, height: 30 })
#
# start_event.connect_with(task_1)
# task_1.connect_with(task_2)
# task_2.connect_with(task_1)
#
# Example of explicite serializing and deserializing structures in ruby:
# data = Marshal.dump(graph)
# graph = Marshal.load(data)
module Bpmn
  module Graph
    class Graph
      include ::Bpmn::Graph::Building
      include ::Bpmn::Graph::Wrapping

      def extend_size_if_needed
        width = representation.position[:width]
        height = representation.position[:height]

        get_elements(type: :node).each do |node|
          node_boundaries = node.representation.boundaries
          width = node_boundaries[:right] if node_boundaries[:right] > width
          height = node_boundaries[:bottom] if node_boundaries[:bottom] > height
        end

        representation.update_position(width: width + 20, height: height + 20)
      end
    end
  end
end