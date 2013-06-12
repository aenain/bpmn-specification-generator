require './app.rb'
require 'shoulda'
require 'minitest/autorun'
require 'active_support/inflector'

class Test::Unit::TestCase
  def assert_full_match(graph)
    assert_equal graph.entry_nodes, graph.end_nodes
    assert_equal 1, graph.entry_nodes.count
    assert_equal Bpmn::Graph::MatchedFragment, graph.entry_nodes.first.class
  end

  def assert_entry_nodes(fragment, *nodes)
    assert_equal nodes.flatten, fragment.entry_nodes
  end

  def assert_end_nodes(fragment, *nodes)
    assert_equal nodes.flatten, fragment.end_nodes
  end

  def assert_connected(node_1, node_2)
    assert node_1.forward_nodes.include?(node_2), "Node expected to be in forward_nodes."
    assert node_2.back_nodes.include?(node_1), "Node expected to be in back_nodes."
  end

  # Example structures (notice that root element is always a pattern's name):
  # {
  #   :sequence => [
  #     :task,
  #     { :sequence => [:task, :task] }
  #   ]
  # }
  #
  # {
  #   :multi_merge => [
  #     :task,
  #     [
  #       { :sequence => [:task, :task] },
  #       { :sequence => [:task, :task] }
  #     ],
  #     :task
  #   ]
  # }
  def assert_pattern_structure(fragment, structure)
    # go directly to the matched fragment's nodes
    fragment = fragment.entry_nodes.first if fragment.respond_to?(:entry_nodes) && !fragment.kind_of?(Bpmn::Graph::MatchedFragment)

    pattern_name = structure.keys.first
    structure = structure.values.first
    nodes = fragment.entry_nodes

    assert_equal pattern_name, fragment.pattern_name

    structure.each_with_index do |structure_or_type, index|
      nodes = nodes.map(&:forward_nodes).flatten.uniq if index > 0

      expected_forward_nodes_count = if index < structure.count - 1
                                       structure[index + 1].respond_to?(:count) ? structure[index + 1].count : 1
                                     else
                                       0
                                     end

      nodes.each do |node|
        assert_forward_node_count(node, expected_forward_nodes_count)
      end

      if structure_or_type.kind_of?(Array)
        structure_or_type.each_with_index do |nested_structure_or_type, nested_index|
          node = nodes[nested_index]

          if nested_structure_or_type.kind_of?(Hash)
            assert_pattern_structure(node, nested_structure_or_type)
          else
            assert_node_type(node, nested_structure_or_type)
          end
        end
      elsif structure_or_type.kind_of?(Hash)
        assert_pattern_structure(nodes.first, structure_or_type)
      else
        nodes.each do |node|
          assert_node_type(node, structure_or_type)
        end
      end
    end
  end

  def assert_forward_node_count(node, count)
    actual_count = node.forward_nodes.count
    assert_equal count, actual_count, "Node expected to have #{count} forward nodes but has #{actual_count}"
  end

  def assert_node_type(node, type)
    node_type = node.class.name.demodulize.underscore.to_sym
    assert_equal type, node_type, "Node expected to be of type #{type} but was #{node_type}"
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