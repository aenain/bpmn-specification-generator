require 'active_support/concern'
require 'active_support/inflector'
require 'pry-debugger'

module Bpmn
  module Graph
    module Wrapping
      extend ActiveSupport::Concern

      # 1. changes end_node of entry_node's back_connections to point to the new MatchedFragment.
      # 2. adds entry_node to the new MatchedFragment's entry_nodes.
      # 3. changes start_node of connections that point outside the fragment to the new MatchedFragment.
      # 4. changes parent of the nodes to self
      def wrap
        clasp_entry_nodes
        clasp_inner_nodes
        clasp_end_nodes
      end

      def clasp_entry_nodes
        entry_nodes.each do |node|
          node.back_connections.each do |connection|
            node.remove_back_connection(connection)
            connection.end_node = self
            add_back_connection(connection)
          end

          clasp_parent_aside_node(node, :entry)
          self.parent ||= node.parent
          node.parent = self
        end
      end

      def clasp_inner_nodes
        inner_nodes.each do |node|
          node.parent = self
        end if respond_to?(:inner_nodes)
      end

      def clasp_end_nodes
        end_nodes.each do |node|
          node.connections.each do |connection|
            node.remove_connection(connection)
            connection.start_node = self
            add_connection(connection)
          end

          clasp_parent_aside_node(node, :end)
          self.parent ||= node.parent
          node.parent = self
        end
      end

      def clasp_parent_aside_node(node, side)
        if node.parent.respond_to?(:"#{side}_nodes")
          parent_nodes = node.parent.method(:"#{side}_nodes").call

          if parent_nodes.include?(node)
            parent_nodes.delete(node)
            parent_nodes.push(self) unless parent_nodes.include?(self)
          end
        end
      end
    end
  end
end