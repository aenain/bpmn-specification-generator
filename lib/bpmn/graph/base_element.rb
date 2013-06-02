module Bpmn
  module Graph
    class BaseElement
      attr_reader :representation, :ref_id, :name

      def initialize(ref_id: nil, representation: nil, name: nil, **options)
        @ref_id = ref_id
        @representation = representation
        @name = name
      end

      def create_representation(**representation_options)
        @representation = Representation.new(representation_options)
      end
    end
  end
end