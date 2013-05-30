module Bpmn
  module Graph
    class Gateway < BaseElement
      TYPES = %i(exclusive_data exclusive_event inclusive complex parallel)

      attr_accessor :type

      def initialize(type: :exclusive_data, **options)
        raise ArgumentError "undefined gateway type" unless TYPES.include?(type)

        super(options)
        @type = type
      end
    end
  end
end