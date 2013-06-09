require 'active_support/concern'
require 'active_support/inflector'
require 'pry-debugger'

module Bpmn
  module Graph
    module InnerStructuring
      extend ActiveSupport::Concern

      %w(connection node).each do |resource|
        resources = resource.pluralize

        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def add_inner_#{resources}(*#{resources})           # def add_inner_nodes(*nodes)
            inner_#{resources}.concat #{resources}.flatten    #   inner_nodes.concat nodes.flatten
          end                                                 # end

          def add_inner_#{resource}(#{resource})              # def add_inner_node(node)
            inner_#{resources} << #{resource}                 #   inner_nodes << node
          end                                                 # end

          def remove_inner_#{resources}(*#{resources})        # def remove_inner_nodes(*nodes)
            inner_#{resources} -= #{resources}.flatten        #   inner_nodes -= nodes.flatten
          end                                                 # end

          def remove_inner_#{resource}(#{resource})           # def remove_inner_node(node)
            inner_#{resources}.delete(#{resource})            #   inner_nodes.delete(node)
          end                                                 # end

          def inner_#{resources}                              # def inner_nodes
            @inner_#{resources} ||= []                        #   @inner_nodes ||= []
          end                                                 # end
        RUBY
      end
    end
  end
end