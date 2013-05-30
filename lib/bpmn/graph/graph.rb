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
      attr_accessor :entry_points

      def initialize(entry_points: [])
        @entry_points = entry_points
      end

      def first_node
        @entry_points.first
      end

      def create_node(type, **node_options)
        klass = "bpmn/graph/#{type}".to_s.camelize.constantize
        klass.new(**node_options).tap do |node|
          self.entry_points.push(node) if type == :start_event
        end
      end
    end
  end
end