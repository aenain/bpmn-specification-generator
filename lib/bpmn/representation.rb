module Bpmn
  class Representation
    attr_accessor :label, :position

    def initialize(label: "", position: { top: 0, left: 0, width: 100, height: 100 })
      @label = label
      @position = position
    end
  end
end