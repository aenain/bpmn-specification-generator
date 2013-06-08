require 'test_helper'

class ExtractorTest < Test::Unit::TestCase
  should "extract sequence in: A -> B" do
    graph = Bpmn::Graph::Graph.new
    tasks = 2.times.map { graph.create_node(:task, ref_id: rand(100)) }
    tasks.first.connect_with(tasks.last)
    graph.add_entry_node(tasks.first)
    graph.add_end_node(tasks.last)

    extract_graph(graph)

    assert_full_match(graph)
    assert_entry_nodes(graph, tasks.first)
    assert_end_nodes(graph, tasks.last)
    assert_connected(tasks.first, tasks.last)
  end

  should "extract sequence of sequence and node in: A -> B -> C" do
    graph = Bpmn::Graph::Graph.new
    tasks = 3.times.map { graph.create_node(:task, ref_id: rand(100)) }
    tasks[0].connect_with(tasks[1])
    tasks[1].connect_with(tasks[2])
    graph.add_entry_node(tasks.first)
    graph.add_end_node(tasks.last)

    extract_graph(graph)

    assert_full_match(graph)
    assert_entry_nodes(graph, tasks.first)
    assert_equal [tasks.last], graph.end_nodes.first.end_nodes.first.end_nodes

    assert_equal [tasks[0]], graph.entry_nodes.first.entry_nodes
    assert_equal Bpmn::Graph::MatchedFragment, graph.entry_nodes.first.end_nodes.first.class
    assert_equal tasks[1..-1], graph.entry_nodes.first.end_nodes.first.nodes
  end

  should "extract multiple merge in: A -> [B, C] -> D" do
    graph = Bpmn::Graph::Graph.new
    tasks = 4.times.map { graph.create_node(:task, ref_id: rand(100)) }
    tasks[0].connect_with(tasks[1])
    tasks[0].connect_with(tasks[2])
    tasks[1].connect_with(tasks[3])
    tasks[2].connect_with(tasks[3])
    graph.add_entry_node(tasks.first)
    graph.add_end_node(tasks.last)

    extract_graph(graph)

    assert_full_match(graph)
    assert_entry_nodes(graph, tasks.first)
    assert_end_nodes(graph, tasks.last)

    assert_connected(tasks[0], tasks[1])
    assert_connected(tasks[0], tasks[2])
    assert_connected(tasks[1], tasks[3])
    assert_connected(tasks[2], tasks[3])
  end

  should "extract sequence and then multiple merge in: A -> [B -> C, D -> E] -> F" do
    graph = Bpmn::Graph::Graph.new
    tasks = 6.times.map { graph.create_node(:task, ref_id: rand(100)) }
    tasks[0].connect_with(tasks[1])
    tasks[0].connect_with(tasks[2])
    tasks[1].connect_with(tasks[3])
    tasks[2].connect_with(tasks[4])
    tasks[3].connect_with(tasks[5])
    tasks[4].connect_with(tasks[5])
    graph.add_entry_node(tasks.first)
    graph.add_end_node(tasks.last)

    extract_graph(graph)

    assert_full_match(graph)
    assert_entry_nodes(graph, tasks.first)
    assert_end_nodes(graph, tasks.last)

    assert_connected(tasks[1], tasks[3])
    assert_connected(tasks[2], tasks[4])
  end
end