module Bpmn
  module Graph
    class BaseElement
      attr_reader :representation, :ref_id

      def initialize(ref_id: nil, representation: nil)
        @ref_id = ref_id
        @representation = representation
      end

      def create_representation(**representation_options)
        @representation = Representation.new(representation_options)
      end
    end
  end
end