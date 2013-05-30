require 'active_support/inflector'
require 'nokogiri'
require 'json'
require 'jsonify'

# Example implementation of whole persistance layer
#
# represents a diagram which has 
# class Diagram < ActiveRecord::Base
#   attr_accessible :title
#   # git: 'git://github.com/aenain/serialize-activerecord.git'
#   serialize :graph, format: :marshal, gzip: true

#   belongs_to :graph_representable, polymorphic: true
# end

# class BusinessModel < ActiveRecord::Base
#   has_one :diagram, as: :graph_representable, conditions: %("diagrams"."patterns_extracted" <> '1')
#   has_one :diagram_with_patterns, class_name: "Diagram", conditions: %("diagrams"."patterns_extracted" = '1'), as: :graph_representable
#   has_one :logical_specification, as: :logically_specificable

#   validates :diagram, :description, presence: true
# end

# class BusinessPattern < ActiveRecord::Base
#   attr_accessible :priority
#   has_one :diagram, as: :graph_representable

#   validates :diagram, :description, presence: true
# end

# class LogicalSpecification < ActiveRecord::Base
#   belongs_to :logically_specificable, polymorphic: true
# end

module Graph
  module Bpmn
    # parses xml and builds whole structure
    class XmlParser
      attr_reader :raw, :xml, :graph

      def initialize(raw)
        @raw = raw
      end

      def parse
        @xml = Nokogiri::XML(raw)
        @graph = Graph.new

        # TODO!
        # build whole structure of nodes and connectors.
        # enclose structure inside of a default swimlane inside of a default pool.

        graph
      end
    end

    # recognizes patterns from the given list in the graph and marks nodes accordingly.
    class PatternExtractor
      attr_reader :graph, :patterns

      # patterns - list of graphs containing patterns
      def initialize(graph, patterns)
        @graph = graph
        @patterns = patterns
      end

      def extract
        # TODO! do the magic :D
        graph
      end
    end

    # represents pattern, e.g. van der Alst's
    class Pattern < Graph
      attr_accessor :prority

      def initialize(priority: 1, **options)
        super(options)
        @priority = priority
      end
    end

    # represents partial or whole business process model.
    # every graph consists of at least one pool and one swimlane.
    class Graph
      attr_accessor :pools

      def initialize(pools: [])
        @pools = pools
      end

      def first_node
        if pools.empty? || pools.first.swimlanes.empty?
          nil
        else
          @pools.first.swimlanes.first.start_node
        end
      end
    end

    class Pool
      attr_accessor :description
      attr_reader :swimlanes

      def initialize(description: "", swimlanes: [])
        @description = description
        @swimlanes = swimlanes
      end
    end

    class Swimlane
      attr_accessor :description, :start_node

      def initialize(description: "", start_node: nil)
        @description = description
        @start_node = start_node
      end

      def create_node(type, **node_options)
        klass = "graph/bpmn/#{type}".to_s.camelize.constantize
        klass.new(**node_options).tap do |node|
          node.swimlane = self
          self.start_node = node if type == :start_event
        end
      end
    end

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

    class Node < BaseElement
      attr_accessor :connections, :back_connections, :swimlane

      def initialize(connections: [], back_connections: [], **options)
        super(options)
        @connections = connections
        @back_connections = back_connections
      end

      def connect_with(node, **connector_options)
        connection = Connector.new(start_node: self, end_node: node, **connector_options)
        @connections << connection
        node.back_connections << connection

        connection
      end
    end

    class Connector < BaseElement
      TYPES = %i(sequence_flow message_flow association)

      attr_accessor :start_node, :end_node, :type

      def initialize(start_node: nil, end_node: nil, type: :sequence_flow, **options)
        raise ArgumentError "undefined connector type" unless TYPES.include?(type)

        super(options)
        @start_node = start_node
        @end_node = end_node
        @type = type
      end
    end

    class Gateway < BaseElement
      TYPES = %i(exclusive_data exclusive_event inclusive complex parallel)

      attr_accessor :type

      def initialize(type: :exclusive_data, **options)
        raise ArgumentError "undefined gateway type" unless TYPES.include?(type)

        super(options)
        @type = type
      end
    end

    class Activity < Node
      attr_accessor :boundary_events
    end

    class Task < Activity
    end

    class SubProcess < Activity
      attr_accessor :entry_points
    end

    class MatchedFragment < Node
      attr_accessor :inside_connections
    end

    class Event < Node
      TYPES = %i(none message timer error rule link terminate)

      attr_accessor :type

      def initialize(type: :none, **options)
        raise ArgumentError "undefined event type" unless TYPES.include?(type)

        super(options)
        @type = type
      end
    end

    class StartEvent < Event
    end

    class IntermediateEvent < Event
    end

    class EndEvent < Event
    end
  end
end

module Graph
  class Representation
    attr_accessor :label, :position

    def initialize(label: "", position: { top: 0, left: 0, width: 100, height: 100 })
      @label = label
      @position = position
    end
  end
end

# example of building graph from scratch
graph = Graph::Bpmn::Graph.new
pool = Graph::Bpmn::Pool.new
swimlane = Graph::Bpmn::Swimlane.new

graph.pools << pool
pool.swimlanes << swimlane

task_1 = swimlane.create_node(:task)
task_1.create_representation(label: "Task 1", position: { top: 50, left: 20, width: 300, height: 100 })

task_2 = swimlane.create_node(:task)
task_2.create_representation(label: "Task 2", position: { top: 100, left: 200, width: 300, height: 100 })

start_event = swimlane.create_node(:start_event, type: :message, id: "20")
start_event.create_representation(label: "S", position: { top: 0, left: 0, width: 30, height: 30 })

start_event.connect_with(task_1)
task_1.connect_with(task_2)
task_2.connect_with(task_1)

# example of explicite serializing and deserializing structures in ruby
data = Marshal.dump(graph)
graph = Marshal.load(data)

# check if it works and puts something to screen :P
p graph.first_node.representation

# example of building json from graph
json = Jsonify::Builder.pretty do |json|
  json.graph do
    node = graph.first_node
    connected_nodes = node.connections.map(&:end_node)

    json.nodes([node] + connected_nodes) do |node|
      json.tag! :class, node.class.name.demodulize
      json.type node.type if node.respond_to?(:type)
      json.label node.representation.label
      json.position node.representation.position
    end
  end
end

puts json