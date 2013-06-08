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
end