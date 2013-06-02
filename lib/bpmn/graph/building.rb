require 'active_support/concern'
require 'active_support/inflector'

module Bpmn
  module Graph
    module Building
      extend ActiveSupport::Concern

      included do
        attr_reader :entry_nodes, :sub_processes

        %w(node connection).each do |resource|
          resources = resource.pluralize

          class_eval <<-LOOKUP, __FILE__, __LINE__ + 1
            def ref_#{resources}                                                              # def ref_nodes
              @ref_#{resources} ||= {}                                                        #   @ref_nodes ||= {}
            end                                                                               # end

            def store_#{resource}_reference(ref_id, #{resource})                              # def store_node_reference(ref_id, node)
              raise ArgumentError "#{resource.camelize}#ref_id can't be nil!" unless ref_id   #   raise ArgumentError "Node#ref_id can't be nil!" unless ref_id
              ref_#{resources}[ref_id] = #{resource}                                          #   ref_nodes[ref_id] = node
            end                                                                               # end

            def lookup_#{resources}(*ref_ids)                                                 # def lookup_nodes(*ref_ids)
              ref_ids.flatten.map { |id| lookup_#{resource}(id) }                             #   ref_ids.flatten.map { |id| lookup_node(id) }
            end                                                                               # end

            def lookup_#{resource}(ref_id)                                                    # def lookup_node(ref_id)
              #{resource} = ref_#{resources}[ref_id]                                          #   node = ref_nodes[ref_id]
                                                                                              #
              unless #{resource}                                                              #   unless node
                sub_processes.each do |process|                                               #     sub_processes.each do |process|
                  #{resource} = process.lookup_#{resource}(ref_id)                            #       node = process.lookup_node(ref_id)
                  break if #{resource}                                                        #       break if node
                end                                                                           #     end
              end                                                                             #   end
                                                                                              #
              #{resource}                                                                     #   node
            end                                                                               # end
          LOOKUP
        end
      end

      def initialize(*args)
        super(*args)
        @sub_processes = []
        @entry_nodes = []
      end

      def first_node
        entry_nodes.first
      end

      def create_node(type, **node_options)
        klass = "bpmn/graph/#{type}".to_s.camelize.constantize
        klass.new(**node_options).tap do |node|
          store_node_reference(node.ref_id, node)
          add_entry_node(node) if type == :start_event
          add_sub_process(node) if type == :sub_process
        end
      end

      def create_connector(**connector_options)
        connector_options[:start_node] = lookup_node(connector_options.delete(:start_ref_id))
        connector_options[:end_node] = lookup_node(connector_options.delete(:end_ref_id))

        Bpmn::Graph::Connector.new(**connector_options).tap do |connector|
          store_connector_reference(connector.ref_id, connector)
        end
      end

      def add_entry_node(node)
        entry_nodes << node
      end

      def add_sub_process(node)
        sub_processes << node
      end
    end
  end
end