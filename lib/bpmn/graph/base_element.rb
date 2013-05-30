module Bpmn
  module Graph
    class BaseElement
      attr_accessor :representation, :id

      def initialize(id: nil, representation: nil)
        @id = id
        @representation = representation
      end

      def create_representation(**representation_options)
        @representation = Representation.new(representation_options)
      end
    end
  end
end