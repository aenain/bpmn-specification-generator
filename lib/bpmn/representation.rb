module Bpmn
  class Representation
    attr_accessor :name
    attr_reader :position, :waypoints

    def initialize(name: "", position: {}, boundaries: {}, waypoints: [])
      @name = name
      @waypoints = waypoints
      @position = position || { top: 0, left: 0, width: 100, height: 100 }

      self.boundaries = boundaries unless boundaries.empty?
    end

    def update_position(position = {})
      @position.merge!(position)
    end

    def boundaries
      {
        top:    position[:top],
        left:   position[:left],
        bottom: position[:top] + position[:height],
        right:  position[:left] + position[:width]
      }
    end

    def boundaries=(boundaries)
      position[:top]    = boundaries[:top]
      position[:left]   = boundaries[:left]
      position[:height] = boundaries[:bottom] - boundaries[:top]
      position[:width]  = boundaries[:right] - boundaries[:left]

      boundaries
    end

    def add_waypoint(top: 0, left: 0)
      @waypoints << { top: top, left: left }
    end
  end
end