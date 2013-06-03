module Bpmn
  class Representation
    attr_accessor :name
    attr_reader :position, :waypoints

    def initialize(name: "", position: {}, waypoints: [])
      @name = name
      @position = position || { top: 0, left: 0, width: 100, height: 100 }
      @waypoints = waypoints
    end

    def update_position(top: 0, left: 0, width: 100, height: 100)
      @position.merge!({ top: top, left: left, width: width, height: height })
    end

    def add_waypoint(top: 0, left: 0)
      @waypoints << { top: top, left: left }
    end
  end
end