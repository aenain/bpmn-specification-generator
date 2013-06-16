require 'singleton'

module Bpmn
  module Pattern
    class Base
      include Singleton

      # nil or MatchedFragment
      def self.match(node, pattern_name)
        pattern_class(pattern_name).instance.match(node)
      end

      def self.direction(pattern_name)
        pattern_class(pattern_name).const_get(:DIRECTION)
      end

      def self.pattern_class(pattern_name)
        "bpmn/pattern/#{pattern_name}".camelize.constantize
      end

      # nil or MatchedFragment
      def match(node)
      end

      private

      # Examples:
      # has_conncetions?(node, count: 1)
      # has_connections?(node, count: 1, conditions: { kind: [:task] })
      # has_connections?(node, count: 1, conditions: [{ kind: [:task] }])
      # has_connections?(node, count: 2, conditions: { kind: [:event], type: [:none] })
      # has_connections?(node, count: 2, conditions: [{ kind: [:task] }, { kind: [:sub_process] }])
      # has_connections?(node, count: 3, conditions: [{ kind: [:task] }, { kind: [:sub_process] }, { kind: [:event], type: [:none] }])
      def has_connections?(node, count: 1, conditions: [])
        conditions = [conditions] if conditions.kind_of?(Hash)

        unless conditions.empty? || [1, count].include?(conditions.count)
          raise ArgumentError, "pass as many conditions as looking connections or pass one condition as a hash."
        end

        proper_count = node.connections.count == count
        return unless proper_count

        conditions.empty? || node.forward_nodes.each_with_index.map do |node, index|
          pass_conditions?(node, conditions.fetch(index, conditions.first))
        end.all?
      end

      def has_back_connections?(node, count: 1, conditions: [])
        conditions = [conditions] if conditions.kind_of?(Hash)

        unless conditions.empty? || [1, count].include?(conditions.count)
          raise ArgumentError, "pass as many conditions as looking connections or pass one condition as a hash."
        end

        proper_count = node.back_connections.count == count
        return unless proper_count

        conditions.empty? || node.back_nodes.each_with_index.map do |node, index|
          pass_conditions?(node, conditions.fetch(index, conditions.first))
        end.all?
      end

      def has_entry_nodes?(node, count: 1)
        node.respond_to?(:entry_nodes) && node.entry_nodes.count == count
      end

      def has_nodes?(node, count: 1)
        node.respond_to?(:nodes) && node.nodes.count == count
      end

      def pass_conditions?(node, kind: [:all], type: [:all])
        match_kind?(node, kind) && match_type?(node, type)
      end

      def class_to_kind(klass)
        klass.name.demodulize.underscore.to_sym
      end

      def match_kind?(node, kind = [:all])
        return true if kind == [:all]

        node_kind = class_to_kind(node.class)
        kind.include?(node_kind)
      end

      def match_type?(node, type = [:all])
        return true if type == [:all]

        node.respond_to?(:type) && type.include?(node.type.to_sym)
      end
    end
  end
end