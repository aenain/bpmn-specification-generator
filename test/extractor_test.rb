require 'test_helper'

class ExtractorTest < Test::Unit::TestCase
  should "extract sequence in: A -> B" do
    graph = Bpmn::Graph::Graph.new
    nodes = 2.times.map { graph.create_node(:task, ref_id: rand(100)) }
    fill_graph(graph: graph, nodes: nodes, connection_mapping: { 0 => 1 })

    extract_graph(graph)

    assert_full_match(graph)
    assert_entry_nodes(graph, nodes.first)
    assert_end_nodes(graph, nodes.last)
    assert_connected(nodes.first, nodes.last)
  end

  should "extract sequence of sequence and node in: A -> B -> C" do
    graph = Bpmn::Graph::Graph.new
    nodes = 3.times.map { graph.create_node(:task, ref_id: rand(100)) }
    fill_graph(graph: graph, nodes: nodes, connection_mapping: { 0 => 1, 1 => 2 })

    extract_graph(graph)

    assert_full_match(graph)
    assert_entry_nodes(graph, nodes.first)
    assert_equal [nodes.last], graph.end_nodes.first.end_nodes.first.end_nodes

    assert_equal [nodes[0]], graph.entry_nodes.first.entry_nodes
    assert_equal Bpmn::Graph::MatchedFragment, graph.entry_nodes.first.end_nodes.first.class
    assert_equal nodes[1..-1], graph.entry_nodes.first.end_nodes.first.nodes
  end

  should "extract multiple merge in: A -> [B, C] -> D" do
    graph = Bpmn::Graph::Graph.new
    nodes = 4.times.map { graph.create_node(:task, ref_id: rand(100)) }
    fill_graph(graph: graph, nodes: nodes, connection_mapping: { 0 => [1, 2], [1, 2] => 3 })

    extract_graph(graph)

    assert_full_match(graph)
    assert_entry_nodes(graph, nodes.first)
    assert_end_nodes(graph, nodes.last)

    assert_connected(nodes[0], nodes[1])
    assert_connected(nodes[0], nodes[2])
    assert_connected(nodes[1], nodes[3])
    assert_connected(nodes[2], nodes[3])
  end

  should "extract sequence and then multiple merge in: A -> [B -> C, D -> E] -> F" do
    graph = Bpmn::Graph::Graph.new
    nodes = 6.times.map { graph.create_node(:task, ref_id: rand(100)) }
    fill_graph(graph: graph, nodes: nodes, connection_mapping: { 0 => [1, 2], 1 => 3, 2 => 4, [3, 4] => 5 })

    extract_graph(graph)

    assert_full_match(graph)
    assert_entry_nodes(graph, nodes.first)
    assert_end_nodes(graph, nodes.last)

    assert_connected(nodes[1], nodes[3])
    assert_connected(nodes[2], nodes[4])
  end
end