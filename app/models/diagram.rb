class Diagram < ActiveRecord::Base
  attr_accessible :title

  serialize :graph, format: :marshal, gzip: true

  belongs_to :graph_representable, polymorphic: true
end