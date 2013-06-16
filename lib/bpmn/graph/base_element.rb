module Bpmn
  module Graph
    class BaseElement
      attr_reader :ref_id
      attr_accessor :representation, :parent

      def initialize(ref_id: nil, **options)
        @ref_id = ref_id
        @representation = ::Bpmn::Representation.new({ name: options[:name], position: options[:position] })
      end
    end
  end
end