module Bpmn
  module Graph
    class Event < Node
      TYPES = %i(none message timer error rule link terminate)

      attr_accessor :type

      def initialize(type: :none, **options)
        raise ArgumentError "undefined event type" unless TYPES.include?(type)

        super(**options)
        @type = type
      end
    end
  end
end