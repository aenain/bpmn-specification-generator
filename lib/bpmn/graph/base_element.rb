module Bpmn
  module Graph
    class BaseElement
      attr_reader :representation, :ref_id

      def initialize(ref_id: nil, **options)
        @ref_id = ref_id
        @representation = Representation.new({ name: options[:name], position: options[:position] })
      end
    end
  end
end