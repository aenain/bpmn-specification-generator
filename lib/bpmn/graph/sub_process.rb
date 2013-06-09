module Bpmn
  module Graph
    class SubProcess < Activity
      include ::Bpmn::Graph::Building
      include ::Bpmn::Graph::Wrapping
      include ::Bpmn::Graph::InnerStructuring

      def nodes
        entry_nodes | inner_nodes | end_nodes
      end
    end
  end
end