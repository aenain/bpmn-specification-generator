require './app.rb'
require 'shoulda'
require 'minitest/autorun'

class Test::Unit::TestCase
  def assert_full_match(graph)
    assert_equal graph.entry_nodes, graph.end_nodes
    assert_equal 1, graph.entry_nodes.count
    assert_equal Bpmn::Graph::MatchedFragment, graph.entry_nodes.first.class
  end

  def assert_entry_nodes(graph, *nodes)
    whole_match = graph.entry_nodes.first
    assert_equal nodes.flatten, whole_match.entry_nodes
  end

  def assert_end_nodes(graph, *nodes)
    whole_match = graph.entry_nodes.first
    assert_equal nodes.flatten, whole_match.end_nodes
  end

  def assert_connected(node_1, node_2)
    assert node_1.forward_nodes.include?(node_2)
    assert node_2.back_nodes.include?(node_1)
  end

  def extract_graph(graph)
    Bpmn::Utilities::PatternExtractor.new(graph).extract
  end

  def fill_graph(graph: nil, nodes: [], entry_nodes: [nodes.first], end_nodes: [nodes.last], connection_mapping: {})
    (graph || Bpmn::Graph::Graph.new).tap do |graph|
      connect_nodes(nodes, connection_mapping)
      graph.add_entry_nodes(entry_nodes)
      graph.add_end_nodes(end_nodes)
    end
  end

  def connect_nodes(nodes, mapping)
    mapping.each_pair do |start_ids, end_ids|
      start_ids = [start_ids] unless start_ids.respond_to?(:each)
      end_ids = [end_ids] unless end_ids.respond_to?(:each)

      start_ids.each do |start_id|
        start_node = nodes[start_id]

        end_ids.each do |end_id|
          end_node = nodes[end_id]
          start_node.connect_with(end_node)
        end
      end
    end
  end
end