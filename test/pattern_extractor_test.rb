require 'test_helper'

class PatternExtractorTest < Test::Unit::TestCase
  should "extract sequence in: A -> B" do
    graph = Bpmn::Graph::Graph.new
    nodes = 2.times.map { graph.create_node(:task, ref_id: rand(100)) }
    fill_graph(graph: graph, nodes: nodes, connection_mapping: { 0 => 1 })

    extract_graph(graph)

    assert_full_match(graph)
    assert_pattern_structure(graph, sequence: [:task, :task])
    assert_entry_nodes(graph.entry_nodes.first, nodes.first)
    assert_end_nodes(graph.end_nodes.first, nodes.last)
    assert_connected(nodes.first, nodes.last)
  end

  should "extract sequence in: A -> B using events" do
    graph = Bpmn::Graph::Graph.new
    nodes = %i(start_event end_event).map { |type| graph.create_node(type, ref_id: rand(100)) }
    fill_graph(graph: graph, nodes: nodes, connection_mapping: { 0 => 1 })

    extract_graph(graph)

    assert_full_match(graph)
    assert_pattern_structure(graph, sequence: [:start_event, :end_event])
    assert_entry_nodes(graph.entry_nodes.first, nodes.first)
    assert_end_nodes(graph.end_nodes.first, nodes.last)
    assert_connected(nodes.first, nodes.last)
  end

  should "extract sequence of sequence and node in: A -> B -> C" do
    graph = Bpmn::Graph::Graph.new
    nodes = 3.times.map { graph.create_node(:task, ref_id: rand(100)) }
    fill_graph(graph: graph, nodes: nodes, connection_mapping: { 0 => 1, 1 => 2 })

    extract_graph(graph)

    assert_full_match(graph)
    assert_pattern_structure(graph, sequence: [:task, { sequence: [:task, :task] } ])
    assert_entry_nodes(graph.entry_nodes.first, nodes.first)
    assert_end_nodes(graph.end_nodes.first.end_nodes.first, nodes.last)

    assert_equal [nodes[0]], graph.entry_nodes.first.entry_nodes.to_a
    assert_equal Bpmn::Graph::MatchedFragment, graph.entry_nodes.first.end_nodes.first.class
    assert_equal nodes[1..-1], graph.entry_nodes.first.end_nodes.first.nodes.to_a
  end

  should "extract multiple merge in: A -> [B, C] -> D" do
    graph = Bpmn::Graph::Graph.new
    nodes = 4.times.map { graph.create_node(:task, ref_id: rand(100)) }
    fill_graph(graph: graph, nodes: nodes, connection_mapping: { 0 => [1, 2], [1, 2] => 3 })

    extract_graph(graph)

    assert_full_match(graph)
    assert_pattern_structure(graph, multiple_merge: [:task, [:task, :task], :task])
    assert_entry_nodes(graph.entry_nodes.first, nodes.first)
    assert_end_nodes(graph.end_nodes.first, nodes.last)
  end

  should "extract sequence and then multiple merge in: A -> [B -> C, D -> E] -> F" do
    graph = Bpmn::Graph::Graph.new
    nodes = 6.times.map { graph.create_node(:task, ref_id: rand(100)) }
    fill_graph(graph: graph, nodes: nodes, connection_mapping: { 0 => [1, 2], 1 => 3, 2 => 4, [3, 4] => 5 })

    extract_graph(graph)

    assert_full_match(graph)
    assert_pattern_structure(graph, multiple_merge: [:task, [{ sequence: [:task, :task] }, { sequence: [:task, :task] }], :task])
    assert_entry_nodes(graph.entry_nodes.first, nodes.first)
    assert_end_nodes(graph.end_nodes.first, nodes.last)
  end

  should "extract sequence and then multiple merge in: A -> B -> [C, D] -> F" do
    graph = Bpmn::Graph::Graph.new
    nodes = %w(A B C D E).map { |name| graph.create_node(:task, name: name, ref_id: rand(100)) }
    fill_graph(graph: graph, nodes: nodes, connection_mapping: { 0 => 1, 1 => [2, 3], [2, 3] => 4 })

    extract_graph(graph)

    assert_full_match(graph)
    assert_pattern_structure(graph, multiple_merge: [{ sequence: [:task, :task] }, [:task, :task], :task])
    assert_entry_nodes(graph.entry_nodes.first.entry_nodes.first, nodes.first)
    assert_end_nodes(graph.end_nodes.first, nodes.last)
  end

  should "extract parallel split in: A -> [B, C]" do
    graph = Bpmn::Graph::Graph.new
    nodes = 3.times.map { graph.create_node(:task, ref_id: rand(100)) }
    fill_graph(graph: graph, nodes: nodes, connection_mapping: { 0 => [1, 2] }, end_nodes: nodes[-2..-1])

    extract_graph(graph)

    assert_full_match(graph)
    assert_pattern_structure(graph, parallel_split: [:task, [:task, :task]])
    assert_entry_nodes(graph.entry_nodes.first, nodes.first)
    assert_end_nodes(graph.end_nodes.first, nodes[-2..-1])
  end

  should "extract sequence in: {A: [B -> C]}" do
    sub_process = Bpmn::Graph::SubProcess.new
    node_b, node_c = 2.times.map { sub_process.create_node(:task, ref_id: rand(100)) }

    fill_graph(graph: sub_process, nodes: [node_b, node_c], connection_mapping: { 0 => 1 })

    extract_graph(sub_process)
    assert_full_match(sub_process)
    assert_pattern_structure(sub_process, sequence: [:task, :task])
  end

  should "extract both sequences in: {A: [B -> C, D -> E]}" do
    sub_process = Bpmn::Graph::SubProcess.new
    nodes = 4.times.map { sub_process.create_node(:task, ref_id: rand(100)) }

    fill_graph(graph: sub_process,
               nodes: nodes,
               connection_mapping: { 0 => 2, 1 => 3 },
               entry_nodes: nodes[0..1],
               end_nodes: nodes[2..3])

    extract_graph(sub_process)

    sequences = sub_process.entry_nodes.to_a
    assert sequences.all? { |s| s.pattern_name == :sequence }
    assert_entry_nodes(sequences[0], nodes[0])
    assert_end_nodes(sequences[0], nodes[2])
    assert_entry_nodes(sequences[1], nodes[1])
    assert_end_nodes(sequences[1], nodes[3])
  end

  should "extract parallel split in: A -> {B:[C, D]}" do
    graph = Bpmn::Graph::Graph.new
    node_a = graph.create_node(:task, ref_id: rand(100))
    sub_process = graph.create_node(:sub_process, ref_id: rand(100))
    node_c, node_d = 2.times.map { sub_process.create_node(:task, ref_id: rand(100)) }

    fill_graph(graph: sub_process,
               nodes: [node_c, node_d],
               connection_mapping: {},
               entry_nodes: [node_c, node_d],
               end_nodes: [node_c, node_d])

    fill_graph(graph: graph, nodes: [node_a, sub_process], connection_mapping: { 0 => 1 })

    extract_graph(graph)

    assert_full_match(graph)
    assert_pattern_structure(graph, parallel_split: [:task, :sub_process])
    assert_entry_nodes(graph.entry_nodes.first, node_a)
    assert_end_nodes(graph.end_nodes.first, sub_process)
  end

  should "extract sequences in sub process and then parallel split in: A -> {B: [C -> D, E -> F]}" do
    graph = Bpmn::Graph::Graph.new
    node_a = graph.create_node(:task, ref_id: rand(100))
    sub_process = graph.create_node(:sub_process, ref_id: rand(100))
    nested_nodes = 4.times.map { sub_process.create_node(:task, ref_id: rand(100)) }

    fill_graph(graph: sub_process,
               nodes: nested_nodes,
               connection_mapping: { 0 => 2, 1 => 3 },
               entry_nodes: nested_nodes[0..1],
               end_nodes: nested_nodes[2..3])

    fill_graph(graph: graph, nodes: [node_a, sub_process], connection_mapping: { 0 => 1 })

    extract_graph(graph)

    assert_full_match(graph)
    assert_pattern_structure(sub_process.entry_nodes.first, sequence: [:task, :task])
    assert_pattern_structure(sub_process.entry_nodes.to_a.last, sequence: [:task, :task])
    assert_pattern_structure(graph, parallel_split: [:task, :sub_process])
    assert_entry_nodes(graph.entry_nodes.first, node_a)
    assert_end_nodes(graph.end_nodes.first, sub_process)
  end

  should "extract sequences and then parallel split in: A -> [B -> C, D -> E]" do
    graph = Bpmn::Graph::Graph.new
    nodes = 5.times.map { graph.create_node(:task, ref_id: rand(100)) }
    fill_graph(graph: graph, nodes: nodes, connection_mapping: { 0 => [1, 2], 1 => 3, 2 => 4 }, end_nodes: nodes[-2..-1])

    extract_graph(graph)

    assert_full_match(graph)
    assert_pattern_structure(graph, parallel_split: [:task, [{ sequence: [:task, :task] }, { sequence: [:task, :task] }]])
    assert_entry_nodes(graph.entry_nodes.first, nodes.first)
    assert_end_nodes(graph.end_nodes.first.end_nodes.first, nodes[-2])
    assert_end_nodes(graph.end_nodes.first.end_nodes.to_a.last, nodes[-1])
  end

  should "extract parallel split with gateway: A -> g -> [B, C]" do
    graph = Bpmn::Graph::Graph.new
    tasks = 3.times.map { graph.create_node(:task, ref_id: rand(100)) }
    gateway = graph.create_node(:gateway, ref_id: rand(100), type: :parallel)
    nodes = tasks.insert(1, gateway)
    fill_graph(graph: graph, nodes: nodes, connection_mapping: { 0 => 1, 1 => [2, 3] }, end_nodes: nodes[-2..-1])

    extract_graph(graph)

    assert_full_match(graph)
    assert_pattern_structure(graph, parallel_split: [:task, :gateway, [:task, :task]])
    assert_entry_nodes(graph.entry_nodes.first, nodes[0])
    assert_end_nodes(graph.end_nodes.first, nodes[-2..-1])
  end

  should "extract simple merge in: [A, B] -> C" do
    graph = Bpmn::Graph::Graph.new
    nodes = 3.times.map { graph.create_node(:task, ref_id: rand(100)) }
    fill_graph(graph: graph, nodes: nodes, connection_mapping: { [0, 1] => 2 }, entry_nodes: nodes[0..1])

    extract_graph(graph)

    assert_full_match(graph)
    assert_pattern_structure(graph, simple_merge: [[:task, :task], :task])
    assert_entry_nodes(graph.entry_nodes.first, nodes[0..1])
    assert_end_nodes(graph.end_nodes.first, nodes[-1])
  end
end